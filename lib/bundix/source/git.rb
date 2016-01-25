class Bundix::Source::Git < Bundix::Source::Base
  attr_reader :url, :revision, :submodules, :glob

  def initialize(url, revision, submodules, glob, sha256 = nil)
    @url = url
    @revision = revision
    @submodules = submodules
    @sha256 = sha256
    @glob = glob
  end

  def cache_key
    {
      'type' => type,
      'url' => url,
      'revision' => revision.to_s,
      'submodules' => submodules
    }
  end
end
