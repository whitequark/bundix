require 'bundler'
require 'thor'
require 'bundix'
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
  option :gemfile, type: :string, default: 'Gemfile',
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

    lockfile = Pathname.new(options[:lockfile]).expand_path
    specs = nil

    if options[:lock]
      say("Generating lockfile...", :green)
      gemfile = Pathname.new(options[:gemfile])
      definition = nil
      Dir.chdir(gemfile.dirname) do
        # see: https://github.com/bundler/bundler/issues/3437
        ENV["BUNDLE_GEMFILE"] = options[:gemfile]
        definition = Bundler.definition(true)
        definition.resolve_remotely!
      end
      specs = definition.specs
      create_file(lockfile, definition.to_lock, force: true)
    else
      lockfile = Bundler::LockfileParser.new(Bundler.read_file(options[:lockfile]))
      specs = lockfile.specs
    end

    say("Pre-fetching gems...", :green)
    gems = Bundix::Prefetcher.new(shell).run(specs, Pathname.new(options[:cachefile]))

    say("Generating gemset...", :green)
    manifest = Bundix::Manifest.new(gems, options[:lockfile], options[:target])
    create_file(@options[:target], manifest.to_nix, force: true)
  end

  desc 'prefetch', 'Conveniently wraps nix-prefetch-scripts'
  subcommand :prefetch, Prefetch
end
