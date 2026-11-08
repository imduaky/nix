{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ghostty-bin
  ];
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty-bin;
    installVimSyntax = true;
    enableBashIntegration = true;
    settings = {
      font-family = [ "Jetbrains mono" "Noto Sans Mono" "Source Han Sans SC" ] ;
      font-thicken = false;
      cursor-style = "block";
      cursor-style-blink = false;
      mouse-shift-capture = true;
      auto-update = "off";
      # shell-integration-features = ( builtins.concatStringsSep "," [ "no-cursor" "no-sudo" "title" "no-ssh-env" "no-ssh-terminfo" "no-path" ] ); 
      shell-integration-features = "no-cursor";
      keybind = [
        "shift+left=previous_tab"
        "shift+right=next_tab"
      ];
    };
  };
}
