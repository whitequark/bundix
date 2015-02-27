Gem::Specification.new do |s|
  s.name        = 'bundix'
  s.version     = '1.0.1'
  s.licenses    = ['MIT']
  s.homepage    = 'https://github.com/cstrahan/bundix'
  s.summary     = "Creates Nix packages from Gemfiles."
  s.description = "Creates Nix packages from Gemfiles."
  s.authors     = ["Alexander Flatter" "Charles Strahan"]
  s.email       = 'rubycoder@example.com'
  s.files       = Dir["bin/*"] + Dir["lib/**/*.rb"]
  s.bindir      = "bin"
  s.executables = [ "bundix" ]
  s.add_runtime_dependency 'thor', '~> 0.19.1'
end
