with (import <nixpkgs> {});
stdenv.mkDerivation {
  name = "bundix";
  src = ./.;
  phases = "installPhase";
  installPhase = ''
    mkdir -p $out
    makeWrapper $src/bin/bundix $out/bin/bundix \
      --prefix PATH : "${nix.out}/bin" \
      --prefix PATH : "${nix-prefetch-git.out}/bin" \
      --set GEM_PATH "${bundler}/${bundler.ruby.gemPath}"
  '';
  nativeBuildInputs = [makeWrapper];
}
