require 'minitest/autorun'
require 'bundix'

class TestConvert < Minitest::Test
  class PickerStub
    def pick
      PrefetchStub.new
    end
  end

  class PrefetchStub
    def nix_prefetch_url(*args)
      return "nix_prefetch_url_hash"
    end

    def nix_prefetch_git(uri, revision)
      return '{"sha256": "nix_prefetch_git_hash"}'
    end

    def fetch_local_hash(spec)
      return "5891b5b522d5df086d0ff0b110fbd9d21bb4fc7163af34d08286a2e846f6be03" #taken from `man nix-hash`
    end

    def fetch_remotes_hash(spec, remotes)
      return "fetch_remotes_hash_hash"
    end
  end

  def build_gemset(options)
    Bundler.instance_variable_set("@root", Pathname.new(File.expand_path("data", __dir__)))
    ENV["BUNDLE_GEMFILE"] = options[:gemfile]
    options = {:deps => false, :lockfile => "", :gemset => ""}.merge(options)
    converter = Bundix.new(options)
    converter.prefetch_picker = PickerStub.new
    converter.convert()
  end

  def test_empty_gemset
    gemset = build_gemset(
      :gemfile => File.expand_path("data/shex/Gemfile", __dir__),
      :lockfile => File.expand_path("data/shex/Gemfile.lock", __dir__)
    )
    # In debug group
    assert_equal("gem", gemset.dig("byebug", :source, :type))
    assert_equal([:debug], gemset.dig("byebug", :groups))


    # In develop, test groups
    assert_equal("git", gemset.dig("simplecov", :source, :type))

    # From the gemspec
    assert_equal("gem", gemset.dig("yard", :source, :type))
    #assert_equal(gemset.dig("yard"), {})

    assert_equal("gem", gemset.dig("rubysl-socket", :source, :type))
    assert_equal([{engine: "rbx"}], gemset.dig("rubysl-socket", :platforms))

    # "main gem" - referred to by 'gemspec'
    assert_equal("path", gemset.dig("shex", :source, :type))
  end
end

class TestPlatformMapping < Minitest::Test
  def test_mapping
    assert_includes(Bundix::PLATFORM_MAPPING["ruby_22"], {engine: "ruby", version: "2.2"})
    assert_includes(Bundix::PLATFORM_MAPPING["ruby_22"], {engine: "rbx", version: "2.2"})
    assert_includes(Bundix::PLATFORM_MAPPING["ruby_22"], {engine: "maglev", version: "2.2"})
  end
end
