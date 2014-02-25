## Changelog

## 0.0.16

* Added handy task to remote edit settings file.

## 0.0.15

* Added new SSHKit backend called SshCommand. It adds support to run interactive commands, example like `rails console`.
* Added rails rake task to create datbase backup and restore. You can check `rake -T`
* Optimized to run rails console task via SshCommand backend
* Added a new task `rails:less_log` to show the current log file via `less`
* Update Handy with a new task `config:settings:get` to download remote stage config to local folder.

## 0.0.14

* Added airbrake deploy notification task.

## 0.0.13

## 0.0.12

* Updated recipe git to update remote with new tags.
* Remove the old settings before upload a new one.
* Added files recipes to dowload remote files. Use `current` folder to search settings.
* Use capistrano method to get revison timestamp for git tagging.


## 0.0.11

* Added support to manage https://github.com/bigbinary/handy config settings files.
* Added recipe to git tag the deployed branch

## 0.0.10

## 0.0.9

## 0.0.8

## 0.0.7

* monkey patch SSHKit because capistrano wont to use blocks for execute.

## 0.0.6

* Added deploy notifiction of the Honeybadger service.

## 0.0.5

* fixed bug: Removed the custom command bin mapping for rails. Updated the rails console behavior.

## 0.0.4

## 0.0.3

## 0.0.2

## 0.0.1

First release.
