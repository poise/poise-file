# Poise-File Cookbook

[![Build Status](https://img.shields.io/travis/poise/poise-file.svg)](https://travis-ci.org/poise/poise-file)
[![Gem Version](https://img.shields.io/gem/v/poise-file.svg)](https://rubygems.org/gems/poise-file)
[![Cookbook Version](https://img.shields.io/cookbook/v/poise-file.svg)](https://supermarket.chef.io/cookbooks/poise-file)
[![Coverage](https://img.shields.io/codecov/c/github/poise/poise-file.svg)](https://codecov.io/github/poise/poise-file)
[![Gemnasium](https://img.shields.io/gemnasium/poise/poise-file.svg)](https://gemnasium.com/poise/poise-file)
[![License](https://img.shields.io/badge/license-Apache_2-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)

A [Chef](https://www.chef.io/) cookbook to do something.

## Quick Start

To write out a JSON file from node attributes:

```ruby
poise_file '/etc/myapp.json' do
  content node['myapp']
end
```

To update a file in place:

```ruby
poise_file '/etc/hosts' do
  content 'otherhostname'
  pattern 'myhostname'
  pattern_location :replace
end
```

## Resources

### `poise_file`

The `poise_file` resource extends the core `file` resource to support formats
and patterns.

#### Formats

If the file path ends with `.json` or `.yaml`/`.yml` and the `content` property
is a Hash or Array object, it will be automatically converted. You can also
explicitly set the `format` property to `:json` or `:yaml` to force formatting.

#### Patterns

Using replacement patterns allows editing files in-place in a structured manner.
This is similar to the `FileEdit` API or `line` cookbook/resource. The `pattern`
property takes a RegExp object or string pattern to match against. The value of
`pattern_location` controls how the `content` gets used relative to the `pattern`.

* `:replace` – `content` replaces the matching section. If the pattern does not match, the content is not changed.
* `:replace_or_add` – `content` replaces the matching section. If the pattern does not match, the content is appended to the end of the file.
* `:before` – `content` is inserted immediately before the matching section. If the pattern does not match, the content is not changed.
* `:after` – `content` is inserted immediately after the matching section. If the pattern does not match, the content is not changed.

You can also pass a Proc to perform arbitrary manipulations:

```ruby
poise_file '/etc/myapp.conf' do
  pattern proc {|existing_content| existing_content.tr('a-z', 'n-za-m') }
end
```

If you have an in-place editing scenario not handled by these operations, please
let me know by [filing an issue](https://github.com/poise/poise-file/issues/new).

#### Actions

All actions are the same as the core `file` resource.

#### Properties

* `format` – File serialization format. One of `:text`, `:json`, or `:yaml`.
  *(default: auto-detect)*
* `pattern` – Regular expression pattern or object to search for.
* `pattern_location` – Mode to use for the `pattern` replacement. One of
  `:replace`, `:replace_or_add`, `:before`, `:after`. *(default: `:replace_or_add`)*

All other properties as the same as the core `file` resource.

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
