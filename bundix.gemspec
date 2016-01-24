Gem::Specification.new do |s|
  s.name        = 'bundix'
  s.version     = '1.0.4'
  s.licenses    = ['MIT']
  s.homepage    = 'https://github.com/cstrahan/bundix'
  s.summary     = "Creates Nix packages from Gemfiles."
  s.description = "Creates Nix packages from Gemfiles."
  s.authors     = ["Alexander Flatter", "Charles Strahan", "Michael 'manveru' Fellinger"]
  s.files       = Dir["bin/*"] + Dir["lib/**/*.rb"]
  s.bindir      = "bin"
  s.executables = [ "bundix" ]
end
