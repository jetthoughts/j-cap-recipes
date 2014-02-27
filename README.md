# Capistrano::Recipes
[![Gem Version](https://badge.fury.io/rb/j-cap-recipes.png)](http://badge.fury.io/rb/j-cap-recipes)

A simple number of capistrano recipes to deploy rails application using Capistrano v3.

## Installation

Add this line to your application's Gemfile:

    gem 'j-cap-recipes', group: :development

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install j-cap-recipes

## Usage

In the `Capfile` to include all recipes add:

    require 'j-cap-recipes/default'

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
    require 'j-cap-recipes/airbrake'

Also you need to include rake tasks in your `Rakefile`:

    require 'j-cap-recipes'

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

### Settings

Support to manage https://github.com/bigbinary/handy config files. First should add `require 'j-cap-recipes/settings'` to `Capfile`.
There are tasks available:

- `cap staging config:settings` Show the current staging config files;
- `cap staging config:settings:delete` Remove the custom env settings file;
- `cap staging config:settings:upload` Update the remote config file with local one;
- `cap staging config:settings:get` Download the remote config file to local one
- `cap staging config:settings:edit` Direct editing of the settings file

### Git

First should add `require 'j-cap-recipes/git'` to `Capfile`.
- `cap staging git:release:tag` Create tag in local repo by variable `git_tag_name`
 Example of usage in your `deploy.rb`:

```ruby
set :git_tag_name, proc { Time.now.to_s.gsub(/[\s\+]+/, '_') }
after 'deploy:finished', 'git:release:tag'
```

### Files

Add 'j-cap-recipes/git'` to `Capfile`.
And now you have task to download any remote file to local via:
`bundle exec cap staging "files:download[config/database.yml]"`.
You will find `download.tar` file in current directory with `config/database.yml`.

To download all share folder use:
`bundle exec cap staging "files:download[.]"`

To extract the archive `tar -xvf download.tar -C tmp`

### Airbrake

Add 'j-cap-recipes/airbrake'` to `Capfile`. The original version capistrano task to notify airbrake service support only
Capistrano version 2. Migrate the task to support version 3.

To send Airbrake deploy notification, you should also add hook to `deploy.rb`

```ruby
after 'deploy:finishing', 'airbrake:deploy'
```

You can change the default api key using `ENV['API_KEY']`.


### Rake tasks

Added utility rake task to create database backup for postgresql and rails.

### SSHKit addon

`SSHKit::Backend::SshCommand` a new backend to invoke the ssh command using sytem command `ssh`.
Now you can easy to execute interactive applications with similar changes. Example:

```ruby
namespace :rails do
  desc 'Execute rails console'
  task :console do
    on roles(:app), in: :parallel, backend: :ssh_command do |*args|
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute(:rails, :console)
        end
      end
    end
  end
end
```

And you have a easy and fast way to run remote interactive rails console via command `cap production rails:console`.

```ruby
task :less_log do
  on roles(:app), in: :parallel, backend: :ssh_command do |*args|
    within current_path.join('log') do
      execute(:less, '-R', fetch(:rails_env)+'.log')
    end
  end
end
```

And you have way to look to logs `cap production less_log`.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
