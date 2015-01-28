let
  pkgs = import <nixpkgs> {};
  lib = pkgs.lib;
  #ruby = pkgs.ruby_2_1_3.override { cursesSupport = true; };
  bundlerEnv = pkgs.bundlerEnv;
in

with pkgs; bundlerEnv {
  name = "nokogiri";
  gemset = ./gemset.nix;
  gemfile = ./Gemfile;
  lockfile = ./Gemfile.lock;
  fixes.nokogiri = attrs: {
    buildArgs = [
      "--use-system-libraries"
      "--with-zlib-dir=${zlib}"
      "--with-xml2-lib=${libxml2}/lib"
      "--with-xml2-include=${libxml2}/include/libxml2"
      "--with-xslt-lib=${libxslt}/lib"
      "--with-xslt-include=${libxslt}/include"
      "--with-exslt-lib=${libxslt}/lib"
      "--with-exslt-include=${libxslt}/include"
    ] ++ lib.optional stdenv.isDarwin "--with-iconv-dir=${libiconv}";
  };
}
