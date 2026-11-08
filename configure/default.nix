{ pkgs, config ,lib, inputs, primaryUser, hostPlatform,... }:
{
  imports = [
    ./fonts
    ./etc
    ./software
    ./networking
  ];

  users.users."${primaryUser}" = import ./users/${primaryUser}.nix { inherit pkgs config lib inputs; };

  system.configurationRevision = with inputs; self.rev or self.dirtyRev or null;
  system.primaryUser = "${primaryUser}";  
  system.stateVersion = 6;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "${hostPlatform}";

  
  # since we starting use Determinate Nix,
  # disable this to prevent the upstream nix daemon start
  nix.enable = false;

  nix.settings = {
    #"https://mirror.sjtu.edu.cn/nix-channels/store"
    substituters = [
      "https://cache.nixos.org"
    ];
    experimental-features = "nix-command flakes";
  };
}
