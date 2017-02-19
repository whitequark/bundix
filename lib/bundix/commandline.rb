require 'optparse'
require 'tmpdir'
require 'tempfile'
require 'pathname'
require 'bundix'

class Bundix
  class CommandLine

    DEFAULT_OPTIONS = {
        ruby: 'ruby',
        bundle_pack_path: 'vendor/bundle',
        lockfile: 'Gemfile.lock',
        gemset: 'gemset.nix',
        quiet: false,
        tempfile: nil,
        deps: false,
        project: File.basename(Dir.pwd)
    }

    def self.run
      self.new.run
    end

    def run
      options = parse_options(DEFAULT_OPTIONS.clone)

      handle_magic(options)

      handle_init(options)

      gemset = build_gemset(options)

      save_gemset(gemset)
    end

    def parse_options(options)

      op = OptionParser.new do |o|
        o.on '-m', '--magic', 'lock, pack, and write dependencies' do
          options[:magic] = true
        end

        o.on "--ruby=#{options[:ruby]}", 'ruby version to use for magic and init, defaults to latest' do |value|
          options[:ruby] = value
        end

        o.on "--bundle-pack-path=#{options[:bundle_pack_path]}", "path to pack the magic" do |value|
          options[:bundle_pack_path] = value
        end

        o.on '-i', '--init', "initialize a new shell.nix for nix-shell (won't overwrite old ones)" do
          options[:init] = true
        end

        o.on "--gemset=#{options[:gemset]}", 'path to the gemset.nix' do |value|
          options[:gemset] = File.expand_path(value)
        end

        o.on "--lockfile=#{options[:lockfile]}", 'path to the Gemfile.lock' do |value|
          options[:lockfile] = File.expand_path(value)
        end

        o.on '-d', '--dependencies', 'include gem dependencies' do
          options[:deps] = true
        end

        o.on '-q', '--quiet', 'only output errors' do
          options[:quiet] = true
        end

        o.on '-v', '--version', 'show the version of bundix' do
          puts Bundix::VERSION
          exit
        end
      end

      op.parse!
      $VERBOSE = !options[:quiet]
      options
    end

    def handle_magic(options)
      if options[:magic]
        fail unless system(
          Bundix::NIX_SHELL, '-p', options[:ruby],
          "bundler.override { ruby = #{options[:ruby]}; }",
          "--command", "bundle lock --lockfile=#{options[:lockfile]}")
        fail unless system(
          Bundix::NIX_SHELL, '-p', options[:ruby],
          "bundler.override { ruby = #{options[:ruby]}; }",
          "--command", "bundle pack --all --path #{options[:bundle_pack_path]}")
      end
    end

    class ShellNixContext < Struct.new(:project, :ruby, :gemfile, :lockfile, :gemset)
      def self.from_hash(hash)
        p, r, gf, l, gs = hash.values_at(:project, :ruby, :gemfile, :lockfile, :gemset)
        self.new(p,r,gf,l,gs)
      end

      def bind
        binding
      end

      def path_for(file)
        "./#{Pathname(file).relative_path_from(Pathname('./'))}"
      end

      def gemfile_path
        path_for(gemfile)
      end

      def lockfile_path
        path_for(lockfile)
      end

      def gemset_path
        path_for(gemset)
      end
    end

    def handle_init(options)
      if options[:init]
        if File.file?('shell.nix')
          warn "won't override existing shell.nix"
        else
          File.write('shell.nix', shell_nix_string)
        end
      end
    end

    def shell_nix_string(options)
      tmpl = ERB.new(File.read(File.expand_path('../../template/shell.nix', __dir__)))
      tmpl.result(ShellNixContext.from_hash(options).bind)

#      shell_nix.gsub!('PROJECT', options[:project] )
#      shell_nix.gsub!('RUBY', options[:ruby])
#      shell_nix.gsub!('LOCKFILE', "./#{Pathname(options[:lockfile]).relative_path_from(Pathname('./'))}")
#      shell_nix.gsub!('GEMSET', "./#{Pathname(options[:gemset]).relative_path_from(Pathname('./'))}")
    end

    def build_gemset(options)
      Bundix.new(options).convert
    end

    def object2nix(obj, level = 0)
      Nixer.new(obj, level).serialize
    end

    def save_gemset(gemset)
      tempfile = Tempfile.new('gemset.nix', encoding: 'UTF-8')
      begin
        tempfile.write(object2nix(gemset))
        tempfile.flush
        FileUtils.cp(tempfile.path, options[:gemset])
      ensure
        tempfile.close!
        tempfile.unlink
      end
    end

  end
end
