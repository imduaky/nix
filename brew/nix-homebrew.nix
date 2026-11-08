{ primaryUser, inputs, config, lib, ... }:
{
  imports = [
    ./taps/tinypkg.nix
    ./taps/snapzy.nix
    ./taps/jorgelbg.nix
    ./taps/jurplel.nix
  ];

  nix-homebrew = {
    enable = true;

    # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
    # Dreprecated: Macos 27 no longer use Rosetta
    enableRosetta = false;

    # User owning the Homebrew prefix
    user = "${primaryUser}";
    autoMigrate = true;
  
    # `brew trust` only accepts non-official, fully-qualified tap entries
    # (owner/repo/name). Feeding it bare official casks (e.g. "macdown")
    # makes the activation `brew trust` call fail. nix-darwin also coerces
    # each cask/brew into an attrset, so pull out `.name` and keep only the
    # tap-qualified entries (those containing a "/").
    #trust = {
    #  casks = builtins.filter (lib.hasInfix "/") (map (c: c.name) config.homebrew.casks);
    #  formulae = builtins.filter (lib.hasInfix "/") (map (f: f.name) config.homebrew.brews);
    #};

    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };

    # Optional: Enable fully-declarative tap management
    #
    # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
    mutableTaps = false;
  };
}
