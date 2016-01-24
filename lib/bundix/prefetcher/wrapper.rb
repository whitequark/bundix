require 'json'
require 'open3'
require 'open-uri'

# Wraps `nix-prefetch-scripts` to provide consistent output.
module Bundix::Prefetcher::Wrapper
  extend self

  def git(repo, rev, submodules)
    home = ENV['HOME']
    ENV['HOME'] = "/homeless-shelter"

    cmd = ['nix-prefetch-git', repo, rev, '--hash', 'sha256', '--leave-dotGit']
    cmd << '--fetch-submodules' if submodules

    # nix-prefetch-git returns a full sha25 hash
    base16 = exec(*cmd)
    assert_length!(base16, 64)
    assert_format!(base16, /^[a-f0-9]+$/)

    # base32-encode for consistency
    base32 = exec('nix-hash', '--type', 'sha256', '--to-base32', base16)
    assert_length!(base32, 52)
    assert_format!(base32, /^[a-z0-9]+$/)

    base32
  ensure
    ENV['HOME'] = home
  end

  # Attempt to use the Rubygems.org API, returning nil if anything goes
  # wrong.
  def gem(name, version)
    version = version.to_s

    gems = open("https://rubygems.org/api/v1/versions/#{name}.json"){|f|
      JSON.parse(f.read) }

    gem = gems.detect do |g|
      g["number"] == version && g["platform"] == "ruby"
    end

    if gem && gem["sha"]
      # Rubygems.org was _supposed_ to provide base64 encoded SHA-256 hashes,
      # but as of now the hashes are base16 encoded...
      base16 = gem["sha"]
      base32 = exec('nix-hash', '--type', 'sha256', '--to-base32', base16)
      assert_length!(base32, 52)
      assert_format!(base32, /^[a-z0-9]+$/)

      base32
    end
  rescue Exception
  end

  def url(url)
    hash = exec("nix-prefetch-url #{url}")

    # nix-prefetch-url returns a base32-encoded sha256 hash
    assert_length!(hash, 52)
    assert_format!(hash, /^[a-z0-9]+$/)

    hash
  end

  def assert_length!(string, expected_length)
    return if string.length == expected_length
    raise "Invalid checksum length; expected #{length}, got #{string.length}"
  end

  def assert_format!(string, regexp)
    return if string =~ regexp
    raise "Invalid checksum format: #{string}"
  end

  def exec(*command)
    output, process = Open3.capture2(*command)
    return output.strip.split("\n").last if process.success?
    puts output
    raise "Prefetch failed: #{command.join(' ')}"
  end
end
