namespace :task do
  desc 'Execute the specific rake task'
  task :exec, :command do |task, args|
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, args[:command]
        end
      end
    end
  end
end
