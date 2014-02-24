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
