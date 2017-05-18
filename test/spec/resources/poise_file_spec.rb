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

require 'spec_helper'

describe PoiseFile::Resources::PoiseFile do
  step_into(:poise_file)
  let(:existing_content) { nil }
  around do |ex|
    Dir.mktmpdir('poise_file') do |path|
      ex.metadata[:poise_file_temp_path] = path
      default_attributes['temp_path'] = path
      IO.write("#{temp_path}/test.txt", existing_content) if existing_content
      ex.run
    end
  end

  let(:temp_path) do |example|
    example.metadata[:poise_file_temp_path]
  end

  subject do
    # Actually write out the file.
    run_chef
    # Lazy load any requested file.
    Hash.new {|has, key| IO.read("#{temp_path}/#{key}") }
  end

  describe 'formats' do
    context 'with a .json path' do
      recipe(subject: false) do
        poise_file "#{node['temp_path']}/test.json" do
          content foo: 'bar'
        end
      end

      its(['test.json']) { is_expected.to eq %Q({\n  "foo": "bar"\n}\n) }
    end # /context with a .json path

    context 'with a .json path but string content' do
      recipe(subject: false) do
        poise_file "#{node['temp_path']}/test.json" do
          content "foo\nbar\n"
        end
      end

      its(['test.json']) { is_expected.to eq "foo\nbar\n" }
    end # /context with a .json path but string content

    context 'with a .yaml path' do
      recipe(subject: false) do
        poise_file "#{node['temp_path']}/test.yaml" do
          content 'foo' => 'bar'
        end
      end

      its(['test.yaml']) { is_expected.to eq %Q(---\nfoo: bar\n) }
    end # /context with a .yaml path

    context 'with a .yml path' do
      recipe(subject: false) do
        poise_file "#{node['temp_path']}/test.yml" do
          content 'foo' => 'bar'
        end
      end

      its(['test.yml']) { is_expected.to eq %Q(---\nfoo: bar\n) }
    end # /context with a .yml path

    context 'with a .txt path' do
      recipe(subject: false) do
        poise_file "#{node['temp_path']}/test.txt" do
          content 'foo' => 'bar'
        end
      end

      its(['test.txt']) { is_expected.to eq %Q({"foo"=>"bar"}) }
    end # /context with a .txt path

    context 'with node attributes' do
      recipe(subject: false) do
        poise_file "#{node['temp_path']}/test.txt" do
          content node['network']
        end
      end

      its(['test.txt']) { is_expected.to match /\A\{.*\}\Z/ }
    end # /context with node attributes
  end # /describe formats

  describe 'patterns' do
    describe 'replace' do
      context 'with a simple pattern' do
        let(:existing_content) { "this is\na test\n" }
        recipe(subject: false) do
          poise_file "#{node['temp_path']}/test.txt" do
            content "this is not\n"
            pattern '^this is$'
            pattern_location :replace
          end
        end

        its(['test.txt']) { is_expected.to eq "this is not\na test\n" }
      end # /context with a simple pattern

      context 'with a replacement without a newline' do
        let(:existing_content) { "this is\na test\n" }
        recipe(subject: false) do
          poise_file "#{node['temp_path']}/test.txt" do
            content "this is not"
            pattern '^this is$'
            pattern_location :replace
          end
        end

        its(['test.txt']) { is_expected.to eq "this is not\na test\n" }
      end # /context with a replacement without a newline

      context 'with a pattern that does not match' do
        let(:existing_content) { "this is\na test\n" }
        recipe(subject: false) do
          poise_file "#{node['temp_path']}/test.txt" do
            content "this is not"
            pattern '^this was$'
            pattern_location :replace
          end
        end

        its(['test.txt']) { is_expected.to eq "this is\na test\n" }
      end # /context with a pattern that does not match
    end # /describe replace

    describe 'replace_or_add' do
      context 'with a simple pattern' do
        let(:existing_content) { "this is\na test\n" }
        recipe(subject: false) do
          poise_file "#{node['temp_path']}/test.txt" do
            content "this is not\n"
            pattern '^this is$'
            pattern_location :replace_or_add
          end
        end

        its(['test.txt']) { is_expected.to eq "this is not\na test\n" }
      end # /context with a simple pattern

      context 'with a patten that does not match' do
        let(:existing_content) { "this is\na test\n" }
        recipe(subject: false) do
          poise_file "#{node['temp_path']}/test.txt" do
            content "this is not\n"
            pattern '^this was$'
            pattern_location :replace_or_add
          end
        end

        its(['test.txt']) { is_expected.to eq "this is\na test\nthis is not\n" }
      end # /context with a patten that does not match
    end # /describe replace_or_add

    describe 'before' do
      context 'with a simple pattern' do
        let(:existing_content) { "this is\na test\n" }
        recipe(subject: false) do
          poise_file "#{node['temp_path']}/test.txt" do
            content "probably\n"
            pattern '^a test$'
            pattern_location :before
          end
        end

        its(['test.txt']) { is_expected.to eq "this is\nprobably\na test\n" }
      end # /context with a simple pattern

      context 'with a pattern that already matches' do
        let(:existing_content) { "this is\nprobably\na test\n" }
        recipe(subject: false) do
          poise_file "#{node['temp_path']}/test.txt" do
            content "probably\n"
            pattern '^a test$'
            pattern_location :before
          end
        end

        its(['test.txt']) { is_expected.to eq "this is\nprobably\na test\n" }
      end # /context with a pattern that already matches

      context 'with a pattern that does not match' do
        let(:existing_content) { "this is\na test\n" }
        recipe(subject: false) do
          poise_file "#{node['temp_path']}/test.txt" do
            content "probably\n"
            pattern '^not a test$'
            pattern_location :before
          end
        end

        its(['test.txt']) { is_expected.to eq "this is\na test\n" }
      end # /context with a pattern that does not match
    end # /describe before

    describe 'after' do
      context 'with a simple pattern' do
        let(:existing_content) { "this is\na test\n" }
        recipe(subject: false) do
          poise_file "#{node['temp_path']}/test.txt" do
            content "probably\n"
            pattern '^a test$'
            pattern_location :after
          end
        end

        its(['test.txt']) { is_expected.to eq "this is\na test\nprobably\n" }
      end # /context with a simple pattern

      context 'with a pattern that already matches' do
        let(:existing_content) { "this is\na test\nprobably\n" }
        recipe(subject: false) do
          poise_file "#{node['temp_path']}/test.txt" do
            content "probably\n"
            pattern '^a test$'
            pattern_location :after
          end
        end

        its(['test.txt']) { is_expected.to eq "this is\na test\nprobably\n" }
      end # /context with a pattern that already matches

      context 'with a pattern that does not match' do
        let(:existing_content) { "this is\na test\n" }
        recipe(subject: false) do
          poise_file "#{node['temp_path']}/test.txt" do
            content "probably\n"
            pattern '^not a test$'
            pattern_location :after
          end
        end

        its(['test.txt']) { is_expected.to eq "this is\na test\n" }
      end # /context with a pattern that does not match
    end # /describe after

    context 'with a proc pattern' do
      let(:existing_content) { "this is\na test\n" }
      recipe(subject: false) do
        poise_file "#{node['temp_path']}/test.txt" do
          content "this is not"
          pattern proc {|existing_content| existing_content.gsub(/t/, 'q') }
        end
      end

      its(['test.txt']) { is_expected.to eq "qhis is\na qesq\n" }
    end # /context with a proc pattern

    context 'with a RegExp pattern' do
      let(:existing_content) { "this is\na test\n" }
      recipe(subject: false) do
        poise_file "#{node['temp_path']}/test.txt" do
          content "this is not\n"
          pattern(/^this is$/)
        end
      end

      its(['test.txt']) { is_expected.to eq "this is not\n\na test\n" }
    end # /context with a RegExp pattern
  end # /describe patterns
end
