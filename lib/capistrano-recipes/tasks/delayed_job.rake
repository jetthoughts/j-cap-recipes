namespace :delayed_job do
  desc 'Restart the delayed_job process'
  task :restart do
    invoke('monit:exec', "-g #{fetch(:monit_delayed_job_name)} restart")
  end

  desc 'Stop the delayed_job process'
  task :stop do
    invoke('monit:exec', "-g #{fetch(:monit_delayed_job_name)} stop")
  end

  desc 'Start the delayed_job process'
  task :start do
    invoke('monit:exec', "-g #{fetch(:monit_delayed_job_name)} start")
  end
end

namespace :load do
  task :defaults do
    set :monit_delayed_job_name, 'delayed_job'
  end
end
