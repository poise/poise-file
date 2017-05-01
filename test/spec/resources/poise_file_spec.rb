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


  recipe do
    poise_file "#{node['temp_path']}/test.json" do
      content foo: 'bar'
    end
  end

  it { run_chef; expect(IO.read("#{temp_path}/test.json")).to eq %Q({\n  "foo": "bar"\n}) }
end
