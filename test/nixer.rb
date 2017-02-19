require 'minitest/autorun'
require 'bundix'

class TestNixer < Minitest::Test
  def test_object2nix_hash
    assert_equal(Bundix::object2nix({:a => "x", :b => "7"}), "{\n  a = \"x\";\n  b = \"7\";\n}")
  end

  def test_object2nix_array
    assert_equal(Bundix.object2nix(["a", "7", "string"]), '["7" "a" "string"]')
  end
end
