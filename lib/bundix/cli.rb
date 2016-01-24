require 'bundler'
require 'optparse'
require 'pathname'
require_relative 'prefetcher'
require_relative 'manifest'

module Bundix
  class CLI
    attr_reader :global

    def initialize(argv)
      @argv = argv
      @options = {
        gemfile: 'Gemfile',
        lockfile: 'Gemfile.lock',
        cachefile: File.expand_path('~/.bundix/cache'),
        target: 'gemset.nix',
        lock: true,
        submodules: false,
      }

      @global = OptionParser.new do |o|
        o.banner = "Usage: bundix [options] [subcommand [options]]"
        o.separator ""
        o.separator "List of commands:"
        o.separator ""
        commands.each do |command|
          o.separator send("#{command}_options").help
        end
      end

      @global.order!
    end

    # mostly for fun
    def commands
      methods = self.class.instance_methods(false).map(&:to_s)
      methods.select!{|m| m.end_with?("_options") }
      methods.map{|m| m.sub(/_options$/, '') }
    end

    def expr_options
      OptionParser.new do |o|
        o.banner = "# Create a Nix expression for your project"
        o.separator "bundix expr [options]"
        o.on '-g', "--gemfile[=#{@options[:gemfile]}]", "Path to the project's Gemfile", String do |value|
          @options[:gemfile] = value
        end
        o.on '-l', "--lockfile[=#{@options[:gemfile]}]", "Path to the project's Gemfile.lock", String do |value|
          @options[:lockfile] = value
        end
        o.on '-c', "--cachefile[=#{@options[:gemfile]}]", "Path where bundix caches things", String do |value|
          @options[:cachefile] = value
        end
        o.on '-t', "--targt[=#{@options[:gemfile]}]", "Path to target file", String do |value|
          @options[:target] = value
        end
        o.on '-u', "--[no-]lock", 'Should the lockfile be created/updated?' do |value|
          @options[:lock] = value
        end
      end
    end

    def expr
      lockfile = Pathname.new(@options[:lockfile]).expand_path
      specs = nil

      if @options[:lock]
        puts "Generating lockfile..."
        gemfile = Pathname.new(@options[:gemfile])
        definition = nil
        Dir.chdir(gemfile.dirname) do
          # see: https://github.com/bundler/bundler/issues/3437
          ENV["BUNDLE_GEMFILE"] = @options[:gemfile]
          definition = Bundler.definition(true)
          definition.resolve_remotely!
        end
        specs = definition.specs
        File.write(lockfile, definition.to_lock)
      else
        lockfile = Bundler::LockfileParser.new(Bundler.read_file(@options[:lockfile]))
        specs = lockfile.specs
      end

      puts "Pre-fetching gems..."
      gems = Bundix::Prefetcher.new.run(specs, Pathname.new(@options[:cachefile]))

      puts "Generating gemset..."
      manifest = Bundix::Manifest.new(gems, @options[:lockfile], @options[:target])
      File.write(@options[:target], manifest.to_nix)
    end

    def git_options
      OptionParser.new do |o|
        o.banner = '# Prefetch a git repository'
        o.separator "bundix git URL REVISION"

        o.on '-s', '--[no-]submodules', 'should it prefetch submodules too?' do |value|
          @options[:submodules] = value
        end
      end
    end

    def git
      url, revision = @argv.shift, @argv.shift
      puts Prefetcher::Wrapper.git(url, revision, @options[:submodules])
    end

    def url_options
      OptionParser.new do |o|
        o.banner = 'Prefetches a file from a URL'
        o.separator "bundix url URL"
      end
    end

    def url
      url = @argv.shift
      puts Prefetch::Wrapper.url(url)
    end
  end
end
