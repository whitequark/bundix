require 'minitest/autorun'
require 'bundix'

class TestNixer < Minitest::Test
  def test_object2nix_hash
    assert_equal("{\n  a = \"x\";\n  b = \"7\";\n}", Bundix::Nixer.new({:a => "x", :b => "7"}).serialize)
  end

  def test_object2nix_array
    assert_equal('["7" "a" "string"]',Bundix::Nixer.new(["a", "7", "string"]).serialize)
  end
end
