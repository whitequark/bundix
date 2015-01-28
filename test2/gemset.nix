{
  "httparty" = {
    version = "0.13.3";
    src = {
      type = "git";
      url = "https://github.com/jnunemaker/httparty.git";
      rev = "655ef5ff9983442fb7d3e4bfea874f2f23859af5";
      fetchSubmodules = false;
      sha256 = "1sz8d686f0f8d01m4way9xwmxyhaaj0nlv7sf1wficskqjda9q0j";
    };
    dependencies = [
      "json"
      "multi_xml"
    ];
  };
  "json" = {
    version = "1.8.2";
    src = {
      type = "gem";
      sha256 = "0zzvv25vjikavd3b1bp6lvbgj23vv9jvmnl4vpim8pv30z8p6vr5";
    };
  };
  "multi_xml" = {
    version = "0.5.5";
    src = {
      type = "gem";
      sha256 = "0i8r7dsz4z79z3j023l8swan7qpbgxbwwz11g38y2vjqjk16v4q8";
    };
  };
}