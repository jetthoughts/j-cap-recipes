namespace :rails do
  desc 'Execute rails console'
  task :console do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          row , command = '', nil
          execute(:rails, :console) do |ch, data|
            row += data
            if command && row.include?(command)
              row.sub!(/#{command}(\r\n)?/, '')
              command = nil
            end

            if row.include?('irb(main):')
              print row
              row     = ''
              command = $stdin.gets
              command = "exit\n" if command == nil
              ch.send_data command
              command.chomp!
            end

            if row.include?("\n")
              print row
              row = ''
            end

          end
        end
      end
    end
  end
end
