class Bundix::Prefetcher
  require_relative 'prefetcher/cache'
  require_relative 'prefetcher/wrapper'
  require_relative 'source'
  require_relative 'gem'

  attr_reader :wrapper

  def initialize(wrapper = Wrapper)
    @wrapper = Wrapper
  end

  # @param [Bundler::SpecSet<Bundler::LazySpecification>] specs
  # @param [Pathname] cache_path
  # @return Array<Bundix::Gem>
  def run(specs, cache_path)
    # Bundler flattens all of the dependencies that we care about.
    dep_names = Set.new(specs.map {|s| s.name})
    cache = load_cache(cache_path)

    gems = specs.map do |spec|
      deps = spec.dependencies.map {|dep| dep.name}.select {|dep| dep_names.include?(dep)}.sort
      source = build_source(spec)
      source.sha256 =
        if cache.has?(source)
          puts "Cached #{spec.name} #{spec.version}"
          cache.get(source)
        else
          puts "Prefetching #{spec.name} #{spec.version}"
          prefetch(source)
        end

      Bundix::Gem.new(spec, source, deps)
    end

    gems.each { |gem| cache.set(gem.source) }
    cache.write(cache_path)

    gems
  end

  def build_source(spec)
    source  = spec.source

    case source
    when Bundler::Source::Rubygems
      Bundix::Source::Gem.new(spec.name, spec.version, source.remotes)
    when Bundler::Source::Git
      # TODO: get ref, too
      glob = source.instance_variable_get("@glob")
      Bundix::Source::Git.new(source.uri, source.revision, !!source.submodules, glob)
    when Bundler::Source::Path
      glob = source.instance_variable_get("@glob")
      Bundix::Source::Path.new(source.path.to_s, glob)
    else
      fail "Unhandled source type: #{source.class}"
    end
  end

  # @param [Pathname] cache_path
  # @return [Cache]
  def load_cache(cache_path)
    cache_path.exist? ? Cache.read(cache_path) : Cache.new
  end

  # @param [Bundler::LazySpecification] spec
  def prefetch(source)
    case source
    when Bundix::Source::Gem
      sha = source.rubygems_org? && wrapper.gem(source.name, source.version)
      return sha if sha

      source.urls.find do |url|
        begin
          wrapper.url(url)
        rescue Thor::Error
          nil
        end
      end
    when Bundix::Source::Git
      wrapper.git(source.url, source.revision, source.submodules)
    end
  end
end
