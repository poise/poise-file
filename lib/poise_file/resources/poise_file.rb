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

        # @!attribute pattern
        #   Regular expression pattern to use for an in-place update of the file.
        #   If given a Proc it should take two arguments, the current content of
        #   the file and the resource object.
        #   @see #pattern_location
        #   @return [String, Regexp, Proc, nil, false]
        attribute(:pattern, kind_of: [String, Regexp, Proc, NilClass, FalseClass], default: nil)

        # @!attribute pattern_location
        #   Location to insert the {#content} data at. Must be one of:
        #   * replace: Overwrite the pattern.
        #   * replace_or_add: Overwrite the patter or append to the file if the
        #      pattern is not present.
        #   * before: Insert the {#content} immediately before the pattern if it
        #     doesn't already exist.
        #   * after: Insert the {#content} immediately after the pattern if it
        #     doesn't already exist.
        #   @see #pattern
        #   @return [String, Symbol]
        attribute(:pattern_location, kind_of: [String, Symbol], default: 'replace_or_add')

        private

        # Find the default format based on the file path.
        #
        # @api private
        # @return [String]
        def default_format
          # If we have a pattern, ignore the format system by default. If we
          # have string content, it's just raw content by default.
          return 'text' if pattern || content.is_a?(String)
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

      # File content class for `poise_file`.
      #
      # @api private
      # @see Resource
      class Content < Chef::FileContentManagement::ContentBase
        # Required abstract method for ContentBase. Builds the new content of
        # file in a tempfile or returns nil to not touch the file content.
        #
        # @return [Chef::FileContentManagement::Tempfile, nil]
        def file_for_provider
          if @new_resource.content
            if @new_resource.pattern && @new_resource.format.to_s != 'text'
              raise ArgumentError.new("Cannot use `pattern` property and `format` property together")
            end

            tempfile = Chef::FileContentManagement::Tempfile.new(@new_resource).tempfile
            content = if @new_resource.pattern
              content_for_pattern
            else
              content_for_format
            end
            tempfile.write(content)
            tempfile.close
            tempfile
          else
            nil
          end
        end

        private

        # Build the content when using the edit-in-place mode.
        #
        # @api private
        # @return [String]
        def content_for_pattern
          # Get the base content to start from.
          existing_content = if ::File.exist?(@new_resource.path)
            IO.read(@new_resource.path)
          else
            # Pretend the file is empty if it doesn't already exist.
            ''
          end

          # If we were given a proc, use it.
          if @new_resource.pattern.is_a?(Proc)
            return @new_resource.pattern.call(existing_content, @new_resource)
          end

          # Build the pattern.
          pattern = if @new_resource.pattern.is_a?(Regexp)
            # Should this dup the pattern because weird tracking stuff?
            @new_resource.pattern
          else
            # Deal with newlines at the end of a line because $ matches before
            # newline, not after.
            pattern_string = if @new_resource.content.end_with?("\n")
              @new_resource.pattern.gsub(/\$\Z/, "$\n?")
            else
              @new_resource.pattern
            end
            # Ruby will show a warning if trying to add options to an existing
            # Regexp instance so only use that if it's a string.
            Regexp.new(pattern_string, Regexp::MULTILINE)
          end

          # Run the pattern operation.
          case @new_resource.pattern_location.to_s
          when 'replace'
            # Overwrite the matched section.
            existing_content.gsub!(pattern, @new_resource.content) || existing_content
          when 'replace_or_add'
            # Overwrite the pattern if it matches otherwise append.
            existing_content.gsub!(pattern, @new_resource.content) || (existing_content << @new_resource.content)
          when 'before'
            # Insert the content before the pattern if it doesn't already exist.
            match = pattern.match(existing_content)
            if match
              if match.pre_match.end_with?(@new_resource.content)
                existing_content
              else
                '' << match.pre_match << @new_resource.content << match[0] << match.post_match
              end
            else
              existing_content
            end
          when 'after'
            # Insert the content after the pattern if it doesn't already exist.
            match = pattern.match(existing_content)
            if match
              if match.post_match.start_with?(@new_resource.content)
                existing_content
              else
                '' << match.pre_match << match[0] << @new_resource.content << match.post_match
              end
            else
              existing_content
            end
          else
            raise ArgumentError.new("Unknown file pattern location #{@new_resource.pattern_location.inspect}")
          end
        end

        # Build the content when using format mode (i.e. when not using the
        # edit-in-place mode).
        #
        # @api private
        # @return [String]
        def content_for_format
          case @new_resource.format.to_s
          when 'json'
            require 'chef/json_compat'
            # Make sure we include the trailing newline because YAML has one.
            Chef::JSONCompat.to_json_pretty(@new_resource.content) + "\n"
          when 'yaml'
            require 'yaml'
            YAML.dump(@new_resource.content)
          when 'text'
            @new_resource.content
          else
            raise ArgumentError.new("Unknown file format #{@new_resource.format.inspect}")
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
