{ nixpkgs ? import <nixpkgs> {}
, url
}:
        
with nixpkgs;

# (ab)use fetchurl to download a URL and add it to the nix store
# *without* already knowing its hash.
fetchurl {
  inherit url;
  sha256 = "0000000000000000000000000000000000000000000000000000";
  downloadToTemp = true;
  postFetch = ''
    PATH="$PATH:${stdenv.lib.makeBinPath [ nix ]}"

    sha256="$(nix-hash --base32 --type sha256 --flat "$downloadedFile")"
    printf "%s\n" "$sha256"

    file="$(dirname "$downloadedFile")/$(basename "$url")"
    mv "$downloadedFile" "$file"
    echo "adding to nix store..."
    nix-store --add "$file"

    echo "success! failing outer nix build..."
    exit 1
  '';
}
