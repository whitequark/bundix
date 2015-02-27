# About

Bundix makes it easy to package your Bundler-enabled applications with the Nix
package manager.

# Basic Usage

1. Change to your project's directory.
2. Run `bundix` (or, if you want to additionally update/create your Gemfile.lock: `bundix --lock`).

# Options

    bundix [OPTIONS]
    
      --gemfile PATH             The path to the Gemfile.
      --lockfile PATH            The path to the Gemfile.lock.
      --target PATH              The path to place the nix expression.
      --lock                     Create or update the Gemfile.lock.
