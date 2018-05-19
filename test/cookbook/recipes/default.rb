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

poise_file '/poise_test' do
  content "I'm a little teapot\n"
end

poise_file '/poise_test.json' do
  content ['short and stout', {here: 'is my handle'}]
end

poise_file '/poise_test.yml' do
  content 'here' => 'is my spout', 'when' => ['I', 'get', 'all', 'steamed', 'up']
end

poise_file '/poise_test.toml' do
  content 'here' => 'is my spout', 'when' => ['I', 'get', 'all', 'steamed', 'up']
end

file '/poise_test_pattern' do
  content "I must shout\ntip me over\n"
end

poise_file '/poise_test_pattern' do
  content 'yell'
  pattern 'shout'
end
