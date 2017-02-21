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
