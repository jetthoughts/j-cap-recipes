module SSHKit
  module Backend
    class Netssh
      def execute(*args, &block)
        _execute(*args, &block).success?
      end

      def command_string(args, &block)
        'ssh %s@%s -t "%s"' % [host.username, String(host.hostname), command(*args).to_command]
      end

      private
      def _execute(*args, &block)

        command(*args).tap do |cmd|
          output << cmd
          cmd.started = true
          ssh.open_channel do |chan|
            chan.request_pty if Netssh.config.pty
            chan.exec cmd.to_command do |ch, success|
              chan.on_data do |ch, data|
                if block_given?
                  cmd.stdout = data
                  block.call(ch, data)
                else
                  cmd.stdout      = data
                  cmd.full_stdout += data
                  output << cmd
                end
              end
              chan.on_extended_data do |ch, type, data|
                cmd.stderr = data
                cmd.full_stderr += data
                output << cmd
              end
              chan.on_request("exit-status") do |ch, data|
                cmd.stdout = ''
                cmd.stderr = ''
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

load File.expand_path('../tasks/rails.rake', __FILE__)
