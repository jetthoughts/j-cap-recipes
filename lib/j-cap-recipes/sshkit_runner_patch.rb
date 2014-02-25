require 'sshkit/runners/abstract'

#Patch to support backend option
# Sent PR https://github.com/capistrano/sshkit/pull/117, except constantinize
module SSHKit

  module Runner

    class Abstract

      attr_reader :hosts, :options, :block

      def initialize(hosts, options = nil, &block)
        @hosts   = Array(hosts)
        @options = options || {}
        @block   = block
      end

      private

      def backend(host, &block)
        backend_factory.new(host, &block)
      end

      def backend_factory
        case @options[:backend]
        when Symbol
          SSHKit::Backend.const_get(@options[:backend].to_s.split('_').collect(&:capitalize).join)
        when String
          Kernel.const_get(@options[:backend])
        when nil
          SSHKit.config.backend
        else
          @options[:backend]
        end

      end
    end

  end

end
