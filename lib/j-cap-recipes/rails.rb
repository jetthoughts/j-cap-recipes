require 'sshkit/backends/ssh_command'
require_relative 'sshkit_runner_patch'

load File.expand_path('../tasks/rails.rake', __FILE__)
