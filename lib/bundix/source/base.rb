class Bundix::Source::Base
  attr_accessor :sha256

  def initialize
    raise NotImplementedError
  end

  def type
    self.class.name.split('::').last.downcase
  end

  def hash
    cache_key.hash
  end
end
