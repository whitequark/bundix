let
  pkgs = import <nixpkgs> {};
  lib = pkgs.lib;
  #ruby = pkgs.ruby_2_1_3.override { cursesSupport = true; };

  bundlerEnv = pkgs.bundlerEnv;

in

bundlerEnv {
  name = "rmagick";
  gemset = ./gemset.nix;
  gemfile = ./Gemfile;
  lockfile = ./Gemfile.lock;
  fixes.rmagick = attrs: {
    buildInputs = [ pkgs.pkgconfig ];
    nativeBuildInputs = [ pkgs.imagemagick ];
    buildArgs = [
      "--foo"
      "--bar"
      "--baz"
    ];
  };
}
