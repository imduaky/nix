{ pkgs, lib, config, ... }:
let
  cfg = config.programs.asdf-vm;

  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkBefore
    mkIf
    mkOption
    types
    ;
in
{
  options.programs.asdf-vm = {
    enable = mkEnableOption "asdf-vm";
    package = mkPackageOption pkgs "asdf-vm" {
      default = "asdf-vm";
      example = "pkgs.asdf-vm";
    };
    enableBashIntegration = lib.hm.shell.mkBashIntegrationOption { inherit config; };
    enableFishIntegration = lib.hm.shell.mkFishIntegrationOption { inherit config; };
    enableZshIntegration = lib.hm.shell.mkZshIntegrationOption { inherit config; };

    toolVersions = mkOption {
      type = with types; attrsOf str;
      default = {};
      description = ''
        Attribute set of tool versions to set in {file}`~/.tool-versions`.
        Each attribute name is the plugin name, and the value is the version string.
      '';
      example = {
        nodejs = "18.16.0";
        python = "3.11.3";
      };
    };

    plugins = mkOption {
      type = with types; attrsOf str;
      default = {};
      description = ''
        Attribute set of asdf plugins to install. The attribute name is the plugin name,
        and the value is the Git URL of the plugin repository.
      '';
      example = {
        nodejs = "https://github.com/asdf-vm/asdf-nodejs.git";
      };
    };

    autoClean = mkEnableOption ''
      automatically uninstall asdf tool versions that are not specified in
      `programs.asdf-vm.toolVersions`.
      Only plugins that appear in the `toolVersions` attribute set will be checked;
      versions of manually added plugins will not be removed.
    '';
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.file.".tool-versions" = mkIf (cfg.toolVersions != {}) {
      text = lib.concatStringsSep "\n"
        (lib.mapAttrsToList (name: version: "${name} ${version}") cfg.toolVersions) + "\n";
    };

    home.activation.installAsdfPlugins = let
      pluginNames = lib.unique (builtins.attrNames cfg.plugins ++ builtins.attrNames cfg.toolVersions);
      pluginAddCmds = map (name: let
        urlArg = lib.optionalString (builtins.hasAttr name cfg.plugins) " \"${cfg.plugins.${name}}\"";
      in ''
        if ! ${cfg.package}/bin/asdf plugin list 2>/dev/null | ${pkgs.gnugrep}/bin/grep -Fxq "${name}"; then
          ${cfg.package}/bin/asdf plugin add "${name}"${urlArg}
        fi
      '') pluginNames;
    in lib.hm.dag.entryAfter ["writeBoundary"] (
      lib.optionalString (pluginNames != []) ''
        export ASDF_DIR="${config.home.homeDirectory}/.asdf"
        export ASDF_DATA_DIR="$ASDF_DIR"
        export PATH="${lib.makeBinPath [ pkgs.bash pkgs.coreutils pkgs.curl pkgs.gnugrep pkgs.gnutar pkgs.gzip pkgs.perl pkgs.unzip ]}:$PATH"
        ${lib.concatStringsSep "\n" pluginAddCmds}
        for plugin_dir in "$ASDF_DATA_DIR"/plugins/*; do
          [ -d "$plugin_dir" ] || continue
          if ${pkgs.git}/bin/git -C "$plugin_dir" rev-parse --git-dir >/dev/null 2>&1; then
            if ! ${pkgs.git}/bin/git -C "$plugin_dir" pull --ff-only --quiet >/dev/null 2>&1; then
              printf 'asdf: plugin update failed: %s\n' "''${plugin_dir##*/}"
            fi
          fi
        done
      ''
    );

    home.activation.installAsdfVersions = lib.hm.dag.entryAfter [ "installAsdfPlugins" ] (
      lib.optionalString (cfg.toolVersions != {}) ''
        export ASDF_DIR="${config.home.homeDirectory}/.asdf"
        export ASDF_DATA_DIR="$ASDF_DIR"
        export PATH="${lib.makeBinPath [ pkgs.bash pkgs.coreutils pkgs.curl pkgs.gnugrep pkgs.gnutar pkgs.gzip pkgs.perl pkgs.unzip ]}:$PATH"
        installAsdfVersion() {
          local plugin="$1" version="$2" install_output install_status
          if install_output=$(${cfg.package}/bin/asdf install "$plugin" "$version" 2>&1); then
            printf '%s\n' "$install_output" | ${pkgs.gnused}/bin/sed '/^version .* is already installed$/d; /%/d; s/^/asdf: /'
          else
            install_status=$?
            printf '%s\n' "$install_output" | ${pkgs.gnused}/bin/sed '/^version .* is already installed$/d; /%/d; s/^/asdf: /'
            return "$install_status"
          fi
        }
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList (plugin: version: "installAsdfVersion \"${plugin}\" \"${version}\"") cfg.toolVersions)}
      ''
    );

    home.activation.cleanAsdfVersions = mkIf (cfg.autoClean) (
      let
        cleanCmds = lib.mapAttrsToList (plugin: version: ''
          for ver in $(${cfg.package}/bin/asdf list "${plugin}" 2>/dev/null | ${pkgs.gnused}/bin/sed 's/^[* ]*//;s/ .*//'); do
            if [[ "$ver" != "${version}" ]]; then
              ${cfg.package}/bin/asdf uninstall "${plugin}" "$ver"
            fi
          done
        '') cfg.toolVersions;
      in  
        lib.hm.dag.entryAfter [ "installAsdfVersions" ] (
          lib.optionalString (cfg.toolVersions != {}) ''
            export ASDF_DIR="${config.home.homeDirectory}/.asdf"
            export ASDF_DATA_DIR="$ASDF_DIR"
            ${lib.concatStringsSep "\n" cleanCmds}
          ''
        )
    );

    programs = {
      bash.initExtra = mkIf cfg.enableBashIntegration (
        mkBefore ''
          export PATH="${config.home.homeDirectory}/.asdf/shims:$PATH"

          source <(${cfg.package}/bin/asdf completion bash)
        ''
      );
      fish.interactiveShellInit = mkIf cfg.enableFishIntegration (
        mkBefore ''
          set -gx PATH "${config.home.homeDirectory}/.asdf/shims" $PATH

          eval (${cfg.package}/bin/asdf completion fish)
        ''
      );
      zsh.initContent = mkIf cfg.enableZshIntegration (
        mkBefore ''
          export PATH="${config.home.homeDirectory}/.asdf/shims:$PATH"

          source <(${cfg.package}/bin/asdf completion zsh)
        ''
      );
    };
  };
}
