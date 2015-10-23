require 'bundix/prefetcher'
require 'yaml'
require 'pathname'

class Bundix::Prefetcher::Cache
  class << self
    def read(path)
      path = Pathname.new(path)
      if path.exist?
        new(YAML.load(path.read))
      else
        new
      end
    end
  end

  def initialize(content = {})
    @cache = content
  end

  def has?(source)
    !!get(source)
  end

  def get(source)
    @cache[source.cache_key]
  end

  def set(source)
    return unless source.sha256
    @cache[source.cache_key] = source.sha256
  end

  # @param [Pathname] path
  def write(path)
    path = Pathname.new(path)
    dir = path.dirname
    dir.mkpath unless dir.exist?
    path.open('w') { |file| file.write(YAML.dump(@cache)) }
  end
end
