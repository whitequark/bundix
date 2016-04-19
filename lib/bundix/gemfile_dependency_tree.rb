require 'bundler'
require 'set'

class Bundix::GemfileDependencyTree
  Spec = Struct.new(:name, :groups, :source, :version, :dependencies)

  def self.run(options)
    definition = Bundler::Dsl.evaluate(Bundler.settings[:gemfile], nil, {})
    specs =
      if options.fetch(:cache)
        puts "resolving #{Bundler.settings[:gemfile]} dependencies with cache" if $VERBOSE
        definition.resolve_with_cache!
      else
        puts "resolving #{Bundler.settings[:gemfile]} dependencies remotely" if $VERBOSE
        definition.resolve_remotely!
      end

    unless Bundler.settings[:frozen]
      puts "writing #{Bundler.settings[:lockfile]}" if $VERBOSE
      puts definition.to_lock
      p definition.lock(Bundler.settings[:lockfile])
    end

    result = {}
    definition.dependencies.each do |dependency|
      p specs.map(&:name)
      p specs.map(&:name).size
      new(dependency, specs, dependency.groups).run([], result)
    end

    result
  end

  def initialize(dep, specs, groups)
    @dep = dep
    @spec = specs.find{|s| s.name == dep.name }
    p @spec
    @groups = groups.map(&:to_s)
    @children = dependencies.map{|d| self.class.new(d, specs, groups) }
  end

  def run(seen = Set.new, result = {})
    children = @children.reject{|c| seen.include?(c.name) }
    add_group(result, @spec)

    children.each do |child|
      seen << child.name
      child.run(seen, result)
    end

    result
  end

  def name
    @spec.name
  end

  private

  def add_group(result, dep)
    if result[dep.name]
      result[dep.name].groups |= @groups
    else
      result[dep.name] = Spec.new(
        dep.name,
        @groups,
        dep.source,
        dep.version.to_s,
        dependencies.map(&:name)
      )
    end
  end

  def dependencies
    @spec.dependencies.reject{|d| d.type == :development }
  end
end
