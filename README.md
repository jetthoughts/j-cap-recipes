# Capistrano::Recipes
[![Gem Version](https://badge.fury.io/rb/j-cap-recipes.png)](http://badge.fury.io/rb/j-cap-recipes)

A simple number of capistrano recipes to deploy rails application using Capistrano v3.

## Installation

Add this line to your application's Gemfile:

    gem 'j-cap-recipes', require: false, group: :development

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install j-cap-recipes

## Usage

In the `Capfile` to include all recipes add:

    require 'j-cap-recipes'

If you want to load only specified recipe:

    require 'j-cap-recipes/setup'
    require 'j-cap-recipes/check'
    require 'j-cap-recipes/nginx'
    require 'j-cap-recipes/monit'
    require 'j-cap-recipes/database'
    require 'j-cap-recipes/delayed_job'
    require 'j-cap-recipes/log'
    require 'j-cap-recipes/rails'
    require 'j-cap-recipes/unicorn'
    require 'j-cap-recipes/honeybadger'

### Nginx
### Setup
### Check
### Monit
### Rails

To run remote rails console you should update to the latest gems `capistrano-rbenv` and `capistrano-bundler`
and run command `cap production rails:console`.

To setup a custom `database.yml` config you should provide the directory of the templates

```ruby
set :template_dir, `config/deploy/templates`
```

After you should create a file `database.yml.erb` example:

```yaml
# store your custom template at foo/bar/database.yml.erb `set :template_dir, "foo/bar"`
#
# example of database template

base: &base
  adapter: postgresql
  encoding: unicode
  timeout: 5000
  username: deployer
  password: <%#= ask(:db_password, SecureRandom.base64(6)) && fetch(:db_password) %>
  host: localhost
 port: 5432

test:
  database: <%= fetch(:application) %>_test
  <<: *base

<%= fetch(:rails_env).to_s %>:
  database: <%= fetch(:application) %>_<%= fetch(:rails_env).to_s %>
  <<: *base

```

### Honeybadger

`honeybadger:deploy` - notify the service about deploy and it would be invoked after `deploy:migrate`

## Handy

Support to manage https://github.com/bigbinary/handy config files. First should add `require 'j-cap-recipes/handy'` to `Capfile`.
There are three tasks available:


- `cap staging config:settings` Show the current staging config files;
- `cap staging config:settings:delete` Remove the custom env settings file;
- `cap staging config:settings:upload` Update the remote config file with local one;

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/jetthoughts/j-cap-recipes/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

