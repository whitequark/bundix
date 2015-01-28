let
  pkgs = import <nixpkgs> {};
  lib = pkgs.lib;
  #ruby = pkgs.ruby_2_1_3.override { cursesSupport = true; };

  bundlerEnv = pkgs.bundlerEnv;

in

bundlerEnv {
  name = "hubx";
  gemset = ./gemset.nix;
  gemfile = ./Gemfile;
  lockfile = ./Gemfile.lock;
  fixes.hub = attrs: {
    patches = [ ./blah.patch ];
    preInstall = ''
      echo "PRE-INSTALL"
      echo "PRE-INSTALL"
      echo "PRE-INSTALL"
      echo "PRE-INSTALL"
      echo "PRE-INSTALL"
      echo "PRE-INSTALL"
    '';
  };
}
