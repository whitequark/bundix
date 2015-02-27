{
  "bundix" = {
    version = "1.0.2";
    source = {
      type = "path";
      path = ./.;
      pathString = ".";
    };
    dependencies = [
      "thor"
    ];
  };
  "bundler" = {
    version = "1.8.3";
    source = {
      type = "gem";
      sha256 = "1q8d6z8p46q9zrmpsya23plz6068r14g6vw9vasyj731n5kfsbps";
    };
  };
  "thor" = {
    version = "0.19.1";
    source = {
      type = "gem";
      sha256 = "08p5gx18yrbnwc6xc0mxvsfaxzgy2y9i78xq7ds0qmdm67q39y4z";
    };
    dependencies = [
      "bundler"
    ];
  };
}