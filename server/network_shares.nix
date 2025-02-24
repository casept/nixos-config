{ pkgs, ... }:
let
  anonShare = path: {
    "path" = "${path}";
    "browseable" = "yes";
    "read only" = "yes";
    "guest ok" = "yes";
    "create mask" = "0644";
    "directory mask" = "0755";
    "force user" = "nobody";
    "force group" = "nogroup";
  };
in
{
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "fakepi";
        "netbios name" = "fakepi";
        "security" = "user";
        "hosts allow" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };
      "torrents" = (anonShare "/tank/torrents");
      "leaks" = (anonShare "/tank/leaks");
    };
  };

  # Advertise the share
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
}
