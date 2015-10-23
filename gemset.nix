{
  "bundix" = {
    version = "1.0.4";
    source = {
      type = "path";
      path = ./.;
      pathString = ".";
    };
    dependencies = [
      "thor"
    ];
  };
  "thor" = {
    version = "0.19.1";
    source = {
      type = "gem";
      remotes = ["https://rubygems.org"];
      sha256 = "08p5gx18yrbnwc6xc0mxvsfaxzgy2y9i78xq7ds0qmdm67q39y4z";
    };
  };
}