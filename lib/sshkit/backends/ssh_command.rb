module SSHKit

  module Backend

    class SshCommand < Printer

      def run
        instance_exec(host, &@block)
      end

      def within(directory, &block)
        (@pwd ||= []).push directory.to_s
        yield
      ensure
        @pwd.pop
      end

      def execute(*args, &block)
        result = 'ssh %s@%s -t "%s"' % [host.username, String(host.hostname), command(*args).to_command]
        output << Command.new(result)
        system(result)
      end

    end
  end
end
