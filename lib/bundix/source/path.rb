class Bundix::Source::Path < Bundix::Source::Base
  attr_reader :path, :glob

  def initialize(path, glob)
    @path = path
    @glob = glob
  end

  def cache_key
    nil
  end
end
