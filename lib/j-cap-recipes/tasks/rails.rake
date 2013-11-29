namespace :rails do
  desc 'Execute rails console'
  task :console do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          _execute_interactive(:rails, :console)
        end
      end
    end
  end
end


module SSHKit
  module Backend
    class Netssh
      def _execute_interactive(*args)
        command(*args).tap do |cmd|
          output << cmd
          cmd.started = true
          ssh.open_channel do |chan|
            chan.request_pty if Netssh.config.pty
            chan.exec cmd.to_command do |ch, success|

              chan.on_data do |ch, data|
                #Rails specific console handler
                @row ||= ''
                @row += data
                if data.include?("\n")
                  cmd.stdout      = @row
                  cmd.full_stdout += @row
                  output << cmd
                  @row = ''
                else
                  if data.include?('irb(main):')
                    print data
                    @row = ''
                    command = $stdin.gets
                    command = "exit\n" if command == nil
                    ch.send_data command
                  end
                end
              end

              chan.on_extended_data do |ch, type, data|
                cmd.stderr      = data
                cmd.full_stderr += data
                output << cmd
              end

              chan.on_request("exit-status") do |ch, data|
                cmd.stdout      = ''
                cmd.stderr      = ''
                cmd.exit_status = data.read_long
                output << cmd
              end
              #chan.on_request("exit-signal") do |ch, data|
              #  # TODO: This gets called if the program is killed by a signal
              #  # might also be a worthwhile thing to report
              #  exit_signal = data.read_string.to_i
              #  warn ">>> " + exit_signal.inspect
              #  output << cmd
              #end
              chan.on_open_failed do |ch|
                # TODO: What do do here?
                # I think we should raise something
              end
              chan.on_process do |ch|
                # TODO: I don't know if this is useful
              end
              chan.on_eof do |ch|
                # TODO: chan sends EOF before the exit status has been
                # writtend
              end
            end
            chan.wait
          end
          ssh.loop
        end
      end
    end
  end
end
