{ pkgs, config, lib, hostName,... }:
let
  bashDir = ./bash;

  scriptNames = builtins.sort builtins.lessThan (
    builtins.filter (name:
      let type = builtins.readDir bashDir; in
      type.${name} == "regular" && lib.hasSuffix ".sh" name
    ) (builtins.attrNames (builtins.readDir bashDir))
  );

  sourceLines = map (name: "source ${./bash}/${name}") scriptNames;
in
{
  home.shell.enableBashIntegration = true;
  home.shell.enableShellIntegration = true;
  
  programs.bash.enable = true;
  programs.bash.shellAliases = {
    ls="ls --color=auto";
    ll="ls -al";
    l="ls";
    grep="grep --color=auto";
    rebuildnix="sudo darwin-rebuild switch --flake ~/.config/nix#${hostName}";
    cleannix="sudo -H -u root nix-env --profile /nix/var/nix/profiles/system --delete-generations +10 && sudo -H -u root nix-collect-garbage -d && sudo -H -u root nix store gc";
    getaddr="dscacheutil -q host -a name";
  };

  programs.bash.initExtra = builtins.concatStringsSep "\n" [ ''
    bind -s 'set completion-ignore-case on';
    source '${pkgs.git}/share/bash-completion/completions/git-prompt.sh';
    
  '' 
    (builtins.concatStringsSep "\n" sourceLines)  
  ''
    # fix the ghostty cursor style not working;
    [[ "$TERM_PROGRAM" == "ghostty" ]] && export TERM=xterm-256color;
  '' ];
}
