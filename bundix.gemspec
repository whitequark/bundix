Gem::Specification.new do |s|
  s.name        = 'bundix'
  s.version     = '2.0.1'
  s.licenses    = ['MIT']
  s.homepage    = 'https://github.com/manveru/bundix'
  s.summary     = 'Creates Nix packages from Gemfiles.'
  s.description = 'Creates Nix packages from Gemfiles.'
  s.authors     = ["Michael 'manveru' Fellinger"]
  s.files       = Dir['bin/*'] + Dir['lib/**/*.rb']
  s.bindir      = 'bin'
  s.executables = ['bundix']
end
