{ pkgs, config, lib , ... }:

{
  environment.systemPackages =
    with pkgs; [ 
    vim git git-lfs jq fastfetch tree
    smartmontools zstd fpm nfpm
  ] ++ [
    wget dig iperf3 nexttrace rclone
  ] ++ [
    # gun
    gnupg gawk gnused gnumake 
    gnutar openssl openssh 
    coreutils moreutils cmake 
    expect qemu findutils ripgrep-all ripgrep
  ] ++ [
    age sops
  ] ++ [
    lima-full apacheHttpd ffmpeg android-tools
  ] ++ [
    # curl
    (pkgs.curl.override {
      c-aresSupport = true;
      brotliSupport = true;
      http2Support = true;
      http3Support = true;
      idnSupport = true;
      zlibSupport = true;
      zstdSupport = true;
    })
  ];

  environment.variables = {
    EDITOR = "vim";
  };
}

