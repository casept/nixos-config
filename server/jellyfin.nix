{ pkgs, ... }: {
  services.jellyfin =
    {
      enable = true;
      openFirewall = true;
      user = "media";
      group = "media";
      dataDir = "/tank/jellyfin";
    };

  environment.systemPackages = with pkgs;
    [
      jellyfin
      jellyfin-web
      jellyfin-ffmpeg
    ];
}
