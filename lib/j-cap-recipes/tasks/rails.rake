namespace :rails do
  desc 'Execute rails console'
  task :console do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          c = command_string([:rails, :console])
          info c
          system c
        end
      end
    end
  end
end
