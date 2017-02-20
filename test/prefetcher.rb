require 'minitest/autorun'

require 'bundix/prefetcher'

class TestPrefetcher < Minitest::Test

  def test_db_path
    if %x(which ruby) =~ /store/
      assert_match(%r(nix/db), Bundix::Prefetcher.db_path.to_s)
    end
  end
end
