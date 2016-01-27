class Bundix
  class Source < Struct.new(:spec)
    def convert
      case spec.source
      when Bundler::Source::Rubygems
        convert_rubygems
      when Bundler::Source::Git
        convert_git
      else
        pp spec
        fail 'unkown bundler source'
      end
    end

    def sh(*args)
      Bundix.sh(*args)
    end

    def nix_prefetch_url(*args)
      sh(NIX_PREFETCH_URL, '--type', 'sha256', *args)
    end

    def nix_prefetch_git(uri, revision)
      home = ENV['HOME']
      ENV['HOME'] = '/homeless-shelter'
      sh(NIX_PREFETCH_GIT, '--url', uri, '--rev', revision, '--hash', 'sha256', '--leave-dotGit')
    ensure
      ENV['HOME'] = home
    end

    def fetch_local_hash(spec)
      spec.source.caches.each do |cache|
        path = File.join(cache, "#{spec.name}-#{spec.version}.gem")
        next unless File.file?(path)
        begin
          return nix_prefetch_url("file://#{path}")[SHA256_32]
        rescue
        end
      end

      nil
    end

    def fetch_remotes_hash(spec, remotes)
      remotes.each do |remote|
        begin
          return fetch_remote_hash(spec, remote)
        rescue
        end
      end

      nil
    end

    def fetch_remote_hash(spec, remote)
      hash = nil

      if URI(remote).host == 'rubygems.org'
        uri = "#{remote}/api/v1/versions/#{spec.name}.json"
        puts "Getting SHA256 from: #{uri}" if $VERBOSE
        open uri do |io|
          versions = JSON.parse(io.read)
          if found_version = versions.find{|obj| obj['number'] == spec.version.to_s }
            hash = found_version['sha']
            break
          end
        end
      end

      uri = "#{remote}/gems/#{spec.name}-#{spec.version}.gem"

      if hash
        begin
          nix_prefetch_url(uri, hash)[SHA256_16]
        rescue
          nix_prefetch_url(uri)[SHA256_32]
        end
      else
        nix_prefetch_url(uri)[SHA256_32]
      end
    end

    def convert_rubygems
      remotes = spec.source.remotes.map{|remote| remote.to_s.sub(/\/+$/, '') }
      hash = fetch_local_hash(spec) || fetch_remotes_hash(spec, remotes)
      hash = sh(NIX_HASH, '--type', 'sha256', '--to-base32', hash)[SHA256_32]
      fail "couldn't fetch hash for #{spec.name}-#{spec.version}" unless hash
      puts "#{hash} => #{spec.name}-#{spec.version}.gem" if $VERBOSE

      {
        type: 'gem',
        remotes: remotes,
        sha256: hash
      }
    end

    def convert_git
      revision = spec.source.options.fetch('revision')
      uri = spec.source.options.fetch('uri')
      hash = nix_prefetch_git(uri, revision)[/^\h{64}$/m]
      hash = sh(NIX_HASH, '--type', 'sha256', '--to-base32', hash)[SHA256_32]
      fail "couldn't fetch hash for #{spec.name}-#{spec.version}" unless hash
      puts "#{hash} => #{uri}" if $VERBOSE

      {
        type: 'git',
        url: uri.to_s,
        rev: revision,
        sha256: hash,
        fetchSubmodules: false
      }
    end
  end
end
