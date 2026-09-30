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
    jetbrains-toolbox mpv  google-chrome prismlauncher
    cc-switch claude-code codex moonlight-qt
    # virt-manager - broken
  ];

}
