namespace :rails do
  desc 'Execute rails console'
  task :console do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          row , command = '', ''
          execute(:rails, :console) do |ch, data|
            row += data
            if data.include?("\n")
              print row if command.chomp != row.chomp
              row = ''
            elsif data.include?('irb(main):')
              print row
              row     = ''
              command = $stdin.gets
              command = "exit\n" if command == nil
              ch.send_data command
            end
          end
        end
      end
    end
  end
end
