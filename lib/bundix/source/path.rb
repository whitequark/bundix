module Bundix
  module Source
    class Path < Base
      attr_reader :path
      attr_reader :glob

      def initialize(path, glob)
        @path = path
        @glob = glob
      end

      def cache_key
        nil
      end
    end
  end
end
