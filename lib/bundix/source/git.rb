module Bundix
  module Source
    class Git < Base
      attr_reader :url
      attr_reader :revision
      attr_reader :submodules
      attr_reader :glob

      def initialize(url, revision, submodules, glob, sha256 = nil)
        @url = url
        @revision = revision
        @submodules = submodules
        @sha256 = sha256
        @glob = glob
      end

      def cache_key
        {
          "type" => type,
          "url" => url,
          "revision" => revision.to_s,
          "submodules" => submodules
        }
      end
    end
  end
end

