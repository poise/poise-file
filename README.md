# Poise-File Cookbook

[![Build Status](https://img.shields.io/travis/poise/poise-file.svg)](https://travis-ci.org/poise/poise-file)
[![Gem Version](https://img.shields.io/gem/v/poise-file.svg)](https://rubygems.org/gems/poise-file)
[![Cookbook Version](https://img.shields.io/cookbook/v/poise-file.svg)](https://supermarket.chef.io/cookbooks/poise-file)
[![Coverage](https://img.shields.io/codecov/c/github/poise/poise-file.svg)](https://codecov.io/github/poise/poise-file)
[![Gemnasium](https://img.shields.io/gemnasium/poise/poise-file.svg)](https://gemnasium.com/poise/poise-file)
[![License](https://img.shields.io/badge/license-Apache_2-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)

A [Chef](https://www.chef.io/) cookbook to do something.

## Quick Start

TODO.

## Recipes

* `poise-file::default` – Do something.

## Attributes

* `node['poise-file']['something']` – Something.

## Resources

### `poise_file`

The `poise_file` resource installs and configures Monit.

```ruby
poise_file 'poise_file' do
  something value
end
```

#### Actions

* `:something` – Something. *(default)*

#### Properties

* `something` – Something. *(name attribute)*

## Sponsors

Development sponsored by [SAP](https://www.sap.com/).

The Poise test server infrastructure is sponsored by [Rackspace](https://rackspace.com/).

## License

Copyright 2017, Noah Kantrowitz

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
