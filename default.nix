with (import <nixpkgs> {});

bundlerEnv {
  name = "bundix";
  ruby = ruby_2_1_3;
  gemset = ./gemset.nix;
  gemfile = ./Gemfile;
  lockfile = ./Gemfile.lock;
}
