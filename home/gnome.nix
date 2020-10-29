{ pkgs, stdenv, lib, fetchFromGitHub, dconf, ... }: {
  home.packages = [
    pkgs.gnomeExtensions.gsconnect
    pkgs.gnomeExtensions.caffeine
    (pkgs.callPackage ../pkgs/wintile { })
  ];

  dconf = {
    enable = true;
    settings = {
      "org/gnome/shell".enabled-extensions = [
        "gsconnect@andyholmes.github.io"
        "caffeine@patapon.info"
        "wintile@nowsci.com"
      ];
    };
  };
}
