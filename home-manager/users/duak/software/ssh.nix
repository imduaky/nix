{ pkgs, config, lib, ... }:
let
  homeDirectory = config.home.homeDirectory;
  sshHome = ".ssh";
in
{
  programs.ssh = {
    enable = true;
    package = pkgs.openssh;
    enableDefaultConfig = false;
    includes = [
      "/etc/ssh/ssh_config.d/*.conf"
      "${homeDirectory}/${sshHome}/config.d/*.conf"
    ];
    settings = {
      "*" = {
        ForwardAgent = lib.mkDefault false;
        AddKeysToAgent = lib.mkDefault "no";
        ServerAliveInterval = lib.mkDefault 0;
        ServerAliveCountMax = lib.mkDefault 3;
        HashKnownHosts = lib.mkDefault false;
        UserKnownHostsFile = lib.mkDefault "~/.ssh/known_hosts";
        ControlMaster = lib.mkDefault "no";
        ControlPath = lib.mkDefault "~/.ssh/master-%r@%n:%p";
        ControlPersist = lib.mkDefault "no";

        IdentityFile = "${homeDirectory}/${sshHome}/id_ed25519";
        SendEnv = [ "TERM" ];
        Compression = true;
        SetEnv = {
          TERM = "xterm-256color";
        };
      };
      "github.com" = {
        Hostname = "ssh.github.com";
        User = "git";
        # use 443 to bypass 22 block in some servers
        Port = 22;
      };
    };
  };
}
