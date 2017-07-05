with (import <nixpkgs> {});
let
  ruby = pkgs.ruby_2_4_1;
  bundler = pkgs.bundler.override { inherit ruby; };
  gems = bundlerEnv {
    inherit ruby;
    name = "bundix-gems";
    gemdir = ./.;
  };
in
stdenv.mkDerivation {
  name = "bundix-shell";
  buildInputs = [
    bundler
    (lowPrio gems)
    ruby
    postgresql96
  ];
}
