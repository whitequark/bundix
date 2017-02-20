class Bundix
  class Prefetcher
    def nix_prefetch_url(*args)
      sh(NIX_PREFETCH_URL, '--type', 'sha256', *args)
    rescue
      nil
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
        hash = nix_prefetch_url("file://#{path}")[SHA256_32]
        return hash if hash
      end

      nil
    end

    def fetch_remotes_hash(spec, remotes)
      remotes.each do |remote|
        hash = fetch_remote_hash(spec, remote)
        return remote, hash if hash
      end

      nil
    end

    def fetch_remote_hash(spec, remote)
      uri = "#{remote}/gems/#{spec.name}-#{spec.version}.gem"
      result = nix_prefetch_url(uri)
      return unless result
      result.force_encoding('UTF-8')[SHA256_32]
    rescue => e
      puts "ignoring error during fetching: #{e}"
      puts e.backtrace
      nil
    end
  end

  class BuildFetch < Prefetcher
    def nix_prefetch_url(url)
      sh(NIX_BUILD, '--argstr', 'url', url, FETCHURL_FORCE, &FETCHURL_FORCE_CHECK)
      .force_encoding('UTF-8')
    rescue
      nil
    end
  end

  class Prefetcher
    def self.pick
      if File.writable?("/nix/var/nix/db")
        return BuildFetch.new
      else
        return Prefetcher.new
      end
    end
  end
end
