after 'deploy', 'honeybadger:deploy'
after 'deploy:migrate', 'honeybadger:deploy'

namespace :honeybadger do
  desc <<-DESC
            Notify Honeybadger of the deployment by running the notification on the REMOTE machine.
              - Run remotely so we use remote API keys, environment, etc.
  DESC
  task :deploy do
    on roles(:app), reject: lambda { |h| h.properties.no_release } do
      dry_run         = fetch(:dry_run)
      honeybadger_env = fetch(:honeybadger_env, fetch(:rails_env, 'production'))
      user            = local_user || ENV['USER'] || ENV['USERNAME']
      async_notify    = fetch(:honeybadger_async_notify, false)

      rake_task_args  = "TO=#{honeybadger_env} REPO=#{repo_url} USER=#{user}"
      rake_task_args  << " #{ENV['API_KEY']}" if ENV['API_KEY']
      rake_task_args  << ' DRY_RUN=true' if dry_run

      if async_notify
        rake_task_args << ' nohup'
        rake_task_args << ' >> /dev/null 2>&1 &'
      end

      if dry_run
        info 'DRY RUN: Notification not actually run.'
      else
        within fetch(:release_path) do
          with(rails_env: fetch(:rails_env)) do
            execute :rake, fetch(:honeybadger_deploy_task, 'honeybadger:deploy'), rake_task_args
          end
        end
      end

      info 'Honeybadger Notification Complete.'
    end
  end
end
