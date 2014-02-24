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

  desc 'Execute less on current env log file'
  task :less_log do
    on roles(:app), in: :parallel, backend: :ssh_command do |*args|
      within current_path.join('log') do
        execute(:less, '-R', fetch(:rails_env)+'.log')
      end
    end
  end

end
