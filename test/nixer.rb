require 'minitest/autorun'
require 'bundix'

class TestNixer < Minitest::Test
  def test_object2nix_hash
    assert_equal(Bundix::Nixer.new({:a => "x", :b => "7"}).serialize, "{\n  a = \"x\";\n  b = \"7\";\n}")
  end

  def test_object2nix_array
    assert_equal(Bundix::Nixer.new(["a", "7", "string"]).serialize, '["7" "a" "string"]')
  end
end
