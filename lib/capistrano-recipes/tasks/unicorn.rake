namespace :unicorn do
  desc 'Restart the unicorn process'
  task :restart do
    invoke('monit:exec', "-g #{fetch(:monit_unicorn_name)} restart")
  end

  desc 'Stop the unicorn process'
  task :stop do
    invoke('monit:exec', "-g #{fetch(:monit_unicorn_name)} stop")
  end

  desc 'Start the unicorn process'
  task :start do
    invoke('monit:exec', "-g #{fetch(:monit_unicorn_name)} start")
  end
end

namespace :load do
  task :defaults do
    set :monit_unicorn_name, "unicorn"
  end
end
