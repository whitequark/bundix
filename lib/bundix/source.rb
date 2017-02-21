require 'forwardable'

class Bundix
  class Source
    def initialize(spec, prefetcher)
      @spec, @prefetcher = spec, prefetcher
    end
    attr_reader :spec, :prefetcher

    def convert
      case spec.source
      when Bundler::Source::Rubygems
        convert_rubygems
      when Bundler::Source::Git
        convert_git
      when Bundler::Source::Path
        convert_path
      else
        pp spec
        fail 'unkown bundler source'
      end
    end

    def sh(*args, &block)
      Bundix.sh(*args, &block)
    end

    extend Forwardable

    def_delegators :@prefetcher, :nix_prefetch_url, :nix_prefetch_git, :fetch_local_hash, :fetch_remotes_hash, :fetch_remote_hash

##<Bundler::LazySpecification:0x00000002f8b888
# @__identifier=-3223135743059213996,
# @dependencies=
#  [Gem::Dependency.new("ebnf", Gem::Requirement.new(["~> 1.1"]), :runtime),
#   Gem::Dependency.new("json-ld", Gem::Requirement.new(["~> 2.1"]), :runtime),
#   Gem::Dependency.new("json-ld-preloaded",
#    Gem::Requirement.new(["~> 0.0"]),
#    :runtime),
#   Gem::Dependency.new("rdf", Gem::Requirement.new(["~> 2.2"]), :runtime),
#   Gem::Dependency.new("rdf-xsd", Gem::Requirement.new(["~> 2.0"]), :runtime),
#   Gem::Dependency.new("sparql", Gem::Requirement.new(["~> 2.0"]), :runtime),
#   Gem::Dependency.new("sxp", Gem::Requirement.new(["~> 1.0"]), :runtime)],
# @name="shex",
# @platform="ruby",
# @source=
#  #<Bundler::Source::Path:0x00000002f8bd60
#   @allow_cached=false,
#   @allow_remote=false,
#   @expanded_path=#<Pathname:/home/judson/dev/shex>,
#   @glob="{,*,*/*}.gemspec",
#   @name=nil,
#   @options={"path"=>"."},
#   @original_path=#<Pathname:.>,
#   @path=#<Pathname:.>,
#   @version=nil>,
# @specification=nil,
# @version=Gem::Version.new("0.3.0")>

    def convert_path
      { type: 'path',
        path: Pathname.new("./") + spec.source.path }
    end

    def convert_rubygems
      remotes = spec.source.remotes.map{|remote| remote.to_s.sub(/\/+$/, '') }
      hash = fetch_local_hash(spec)
      remote, hash = fetch_remotes_hash(spec, remotes) unless hash
      hash = sh(NIX_HASH, '--type', 'sha256', '--to-base32', hash)[SHA256_32]
      fail "couldn't fetch hash for #{spec.name}-#{spec.version}" unless hash
      puts "#{hash} => #{spec.name}-#{spec.version}.gem" if $VERBOSE

      { type: 'gem',
        remotes: (remote ? [remote] : remotes),
        sha256: hash }
    end

    def convert_git
      revision = spec.source.options.fetch('revision')
      uri = spec.source.options.fetch('uri')
      output = nix_prefetch_git(uri, revision)
      # FIXME: this is a hack, we should separate $stdout/$stderr in the sh call
      hash = JSON.parse(output[/({[^}]+})\s*\z/m])['sha256']
      fail "couldn't fetch hash for #{spec.name}-#{spec.version}" unless hash
      puts "#{hash} => #{uri}" if $VERBOSE

      { type: 'git',
        url: uri.to_s,
        rev: revision,
        sha256: hash,
        fetchSubmodules: false }
    end
  end
end
