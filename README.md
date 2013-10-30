# Capistrano::Recipes

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'capistrano-recipes', require: false, group: :development

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-recipes

## Usage

In the `Capfile` to include all recipes add:

    require 'capistrano-recipes'

If you want to load only specified recipe:

    require 'capistrano-recipes/setup'
    require 'capistrano-recipes/check'
    require 'capistrano-recipes/nginx'
    require 'capistrano-recipes/monit'
    require 'capistrano-recipes/database'
    require 'capistrano-recipes/delayed_job'
    require 'capistrano-recipes/log'
    require 'capistrano-recipes/rails'
    require 'capistrano-recipes/unicorn'

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
