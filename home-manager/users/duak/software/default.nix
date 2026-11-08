{ pkgs , ... }:
{
  imports = [
    ./vscode.nix
    ./ghostty.nix
    ./git.nix
    ./qq.nix
    ./bash.nix
    ./direnv.nix
    ./lima.nix
    ./ssh.nix
    ./asdf.nix
    ./aria2c.nix
    ./fcitx5.nix
    ./gnupg.nix
  ];
  home.packages = with pkgs; [
    mpv  google-chrome prismlauncher jetbrains-toolbox
    cc-switch claude-code codex moonlight-qt jetbrains-toolbox
    # virt-manager  - broken
  ];

}
