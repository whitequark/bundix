require 'bundix'
require 'uri'
require 'digest/sha1'

module Bundix
  # The {Source} class represents all information necessary to fetch the source
  # of one or more gems as required by a Nix derivation.
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

      def components
        [type]
      end

      def hash
        components.hash
      end
    end

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

      def components
        super + [{
          "url" => url,
          "revision" => revision,
          "submodules" => submodules
        }]
      end
    end

    class Gem < Base
      attr_reader :name
      attr_reader :version
      attr_reader :remotes
      attr_reader :urls
      attr_reader :rubygems_url

      def initialize(name, version, remotes, sha256 = nil)
        @name = name
        @version = version
        @remotes = remotes.map do |remote|
          remote = remote.to_s.sub(%r{/$}, "")
        end
        @sha256 = sha256
        @urls = @remotes.map do |remote|
          "#{remote}/gems/#{name}-#{version}.gem"
        end
        @rubygems_url = @urls.detect do |url|
          URI.parse(url).host == "rubygems.org"
        end
      end

      def rubygems_org?
        @rubygems_url != nil
      end

      def components
        super + remotes.sort
      end
    end

    class Path < Base
      attr_reader :path
      attr_reader :glob

      def initialize(path, glob)
        @path = path
        @glob = glob
      end
    end
  end

  class Dependency
    def initialize(dependency)
      @dependency = dependency
    end

    def name
      @dependency.name
    end
  end

  class Gem
    attr_reader :source
    attr_reader :dependencies

    def initialize(spec, source, dependencies)
      @spec = spec
      @source = source
      @dependencies = dependencies
    end

    def name
      @spec.name
    end

    def drv_name
      "#{@spec.name}-#{version}"
    end

    def version
      @spec.version.to_s
    end
  end
end
