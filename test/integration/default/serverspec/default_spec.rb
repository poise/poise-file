#
# Copyright 2017, Noah Kantrowitz
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

require 'serverspec'
set :backend, :exec

describe file('/poise_test') do
  it { is_expected.to be_a_file }
  its(:content) { is_expected.to eq "I'm a little teapot\n" }
end

describe file('/poise_test.properties') do
  it { is_expected.to be_a_file }
  its(:content) { is_expected.to eq <<-EOH }
[
  "short and stout",
  {
    "here": "is my handle"
  }
]
EOH
end

describe file('/poise_test.json') do
  it { is_expected.to be_a_file }
  its(:content) { is_expected.to eq <<-EOH }
[
  "short and stout",
  {
    "here": "is my handle"
  }
]
EOH
end

describe file('/poise_test.yml') do
  it { is_expected.to be_a_file }
  its(:content) { is_expected.to eq <<-EOH }
---
here: is my spout
when:
- I
- get
- all
- steamed
- up
EOH
end

describe file('/poise_test_pattern') do
  it { is_expected.to be_a_file }
  its(:content) { is_expected.to eq "I must yell\ntip me over\n" }
end
