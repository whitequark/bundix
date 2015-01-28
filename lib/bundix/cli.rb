require 'thor'
require 'bundix'
require 'fileutils'
require 'pathname'

class Bundix::CLI < Thor
  include Thor::Actions
  default_task :expr

  class Prefetch < Thor
    desc 'git URL REVISION', 'Prefetches a git repository'
    def git(url, revision)
      puts Prefetch::Wrapper.git(url, revision)
    end

    desc 'url URL', 'Prefetches a file from a URL'
    def url(url)
      puts Prefetcher::Wrapper.url(url)
    end
  end

  desc "init", "Sets up your project for use with Bundix"
  def init
    raise NotImplemented
  end

  desc 'expr', 'Creates a Nix expression for your project'
  option :gemfile, type: :string, default: 'Gemfile.lock',
                   desc: "Path to the project's Gemfile"
  option :lockfile, type: :string, default: 'Gemfile.lock',
                    desc: "Path to the project's Gemfile.lock"
  option :cachefile, type: :string, default: "#{ENV['HOME']}/.bundix/cache"
  option :target, type: :string, default: 'gemset.nix',
                  desc: 'Path to the target file'
  option :lock, type: :boolean,
                desc: 'Should the lockfile be created/updated?'
  def expr
    require 'bundix/prefetcher'
    require 'bundix/manifest'

    gemfile = Pathname.new(options[:gemfile])
    specs = nil
    definition = nil
    Dir.chdir(gemfile.dirname) do
      definition = Bundler::Definition.build(gemfile.basename, options[:lockfile], {})
      definition.resolve_remotely!
      specs = definition.resolve
    end

    if options[:lock]
      #definition.to_lock
      puts definition.to_lock
      exit 1
    end

    gems = Bundix::Prefetcher.new(shell).run(specs, Pathname.new(options[:cachefile]))

    say("Writing...", :green)
    manifest = Bundix::Manifest.new(gems, options[:lockfile], options[:target])
    create_file(@options[:target], manifest.to_nix, force: true)
  end

  desc 'prefetch', 'Conveniently wraps nix-prefetch-scripts'
  subcommand :prefetch, Prefetch
end
