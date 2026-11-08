{ inputs, ... }:
let
  tapInput = inputs.homebrew-tap-jurplel;
in
{
  # Official Snapzy tap (github:duongductrong/Snapzy ships Casks/snapzy.rb).
  # Tap dir on disk is duongductrong/homebrew-snapzy, so brew refers to the
  # cask as duongductrong/snapzy/snapzy.
  nix-homebrew.taps = {
    "jurplel/homebrew-tap" = tapInput;
  };
  nix-homebrew.trust = {
    taps = [ "jurplel/tap" ];
    casks = [ "jurplel/tap/instant-space-switcher" ];
  };

  homebrew.casks = [
    "jurplel/tap/instant-space-switcher"
  ];
}
