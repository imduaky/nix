{ config, pkgs, lib, ... }:
{
  programs.asdf-vm = {
    enable = true;
    package = pkgs.asdf-vm;
    autoClean = false;
    toolVersions = {
      golang = "1.27.0";
      nodejs = "24.19.0";
      golangci-lint = "2.11.4";
      pnpm = "11.24.0";
      python = "3.14.5";
      rust = "1.98.0";
    };
  };
}
