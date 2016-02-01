Gem::Specification.new do |s|
  s.name        = 'bundix'
  s.version     = '2.0.2'
  s.licenses    = ['MIT']
  s.homepage    = 'https://github.com/manveru/bundix'
  s.summary     = 'Creates Nix packages from Gemfiles.'
  s.description = 'Creates Nix packages from Gemfiles.'
  s.authors     = ["Michael 'manveru' Fellinger"]
  s.files       = Dir['bin/*'] + Dir['lib/**/*.rb']
  s.bindir      = 'bin'
  s.executables = ['bundix']
  s.add_runtime_dependency 'bundler', '~> 1.11.2'
end
