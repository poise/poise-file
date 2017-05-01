#
# Copyright 2017, Noah Kantrowitz
#
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/file_content_management/content_base'
require 'chef/file_content_management/tempfile'
require 'chef/resource/file'
require 'chef/provider/file'
require 'poise'


module PoiseFile
  module Resources
    # (see PoiseFile::Resource)
    # @since 1.0.0
    module PoiseFile
      # A `poise_file` resource to write out a file with some nice helpers.
      #
      # @provides poise_file
      # @action create
      # @action delete
      # @action touch
      # @action create_if_missing
      # @example
      #   poise_file '/etc/myapp.json' do
      #     content listen: 80, debug: false
      #   end
      class Resource < Chef::Resource::File
        include Poise
        provides(:poise_file)
        actions(:create, :delete, :touch, :create_if_missing)

        # @!attribute content
        #   Format to write the file in. `text` is the same as the core `file`
        #   resource, `json` writes the content as a JSON object, `yaml` as a
        #   YAML object.
        #   @return [String, Symbol]
        attribute(:content, kind_of: [String, Hash, Array])

        # @!attribute format
        #   Format to write the file in. `text` is the same as the core `file`
        #   resource, `json` writes the content as a JSON object, `yaml` as a
        #   YAML object.
        #   @return [String, Symbol]
        attribute(:format, kind_of: [String, Symbol], default: lazy { default_format })

        private

        # Find the default format based on the file path.
        #
        # @api private
        # @return [String]
        def default_format
          case path
          when /\.json$/
            'json'
          when /\.ya?ml$/
            'yaml'
          else
            'text'
          end
        end
      end

      class Content < Chef::FileContentManagement::ContentBase
        def file_for_provider
          if @new_resource.content
            tempfile = Chef::FileContentManagement::Tempfile.new(@new_resource).tempfile
            content = case @new_resource.format.to_s
              when 'json'
                require 'chef/json_compat'
                Chef::JSONCompat.to_json_pretty(@new_resource.content) + "\n"
              when 'yaml'
                require 'yaml'
                YAML.dump(@new_resource.content)
              when 'text'
                @new_resource.content
              else
                raise ArgumentError.new("Unknown file format #{@new_resource.format.inspect}")
              end
            tempfile.write(content)
            tempfile.close
            tempfile
          else
            nil
          end
        end
      end

      # Provider for `poise_file`.
      #
      # @see Resource
      # @provides poise_file
      class Provider < Chef::Provider::File
        include Poise
        provides(:poise_file)

        def initialize(new_resource, run_context)
          @content_class = Content
          super
        end
      end
    end
  end
end
