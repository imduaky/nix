{ config, pkgs, lib, ... }:
{
  programs.asdf-vm = {
    enable = true;
    package = pkgs.asdf-vm;
    autoClean = true;
    plugins = {};
    toolVersions = {
      golang = "1.27.0";
      nodejs = "26.13.0";
      golangci-lint = "2.13.1";
      pnpm = "12.18.0";
      python = "3.14.5";
      rust = "1.98.0";
      java = "openjdk-25.0.1";
    };
  };
}
