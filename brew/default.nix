{ pkgs, config, lib, inputs, primaryUser,... }:
let
  allowUpdate = true;
in
{
  imports = [
    ./nix-homebrew.nix
  ];
  homebrew = {
    enable = true;
    taps = builtins.attrNames config.nix-homebrew.taps;
    enableBashIntegration = true;
    caskArgs = {
      appdir = "/Applications";
      require_sha = true;
    };

    onActivation = {
      # Set below option to true to update the brews and casks.
      autoUpdate = allowUpdate;
      upgrade = allowUpdate;
      cleanup = "uninstall";
    };

    brews = [
    ];
    casks = [
      "macdown"
      "1password"
      "telegram"
      "ungoogled-chromium"
      "helium-browser"
      "duckduckgo"
      "linearmouse"
    ];
  };
  
}
