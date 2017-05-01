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
  around do |ex|
    Dir.mktmpdir('poise_file') do |path|
      ex.metadata[:poise_file_temp_path] = path
      default_attributes['temp_path'] = path
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

  context 'with a .json path' do
    recipe(subject: false) do
      poise_file "#{node['temp_path']}/test.json" do
        content foo: 'bar'
      end
    end

    its(['test.json']) { is_expected.to eq %Q({\n  "foo": "bar"\n}\n) }
  end # /context with a .json path

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
end
