module Bundix
  module Source
    class Base
      attr_writer :sha256

      def initialize
        raise NotImplementedError
      end

      def sha256
        @sha256 ||= nil
      end

      def type
        self.class.name.split('::').last.downcase
      end

      def hash
        cache_key.hash
      end
    end
  end
end
