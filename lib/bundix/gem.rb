module Bundix
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

    def version
      @spec.version.to_s
    end
  end
end
