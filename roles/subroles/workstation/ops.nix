{ config, pkgs, ... }: {
  # Allow proprietary derivations
  nixpkgs.config.allowUnfree = true;

  # Podman config in nixOS <= 20.03 is a bit tricky
  environment.systemPackages = with pkgs; [
    podman
    runc
    conmon
    slirp4netns
    fuse-overlayfs
  ];
  users.users.user.subUidRanges = [{
    startUid = 100000;
    count = 65536;
  }];
  users.users.user.subGidRanges = [{
    startGid = 100000;
    count = 65536;
  }];
  environment.etc."containers/policy.json" = {
    mode = "0644";
    text = ''
      {
        "default": [
          {
            "type": "insecureAcceptAnything"
          }
        ],
        "transports":
          {
            "docker-daemon":
              {
                "": [{"type":"insecureAcceptAnything"}]
              }
          }
      }
    '';
  };
  environment.etc."containers/registries.conf" = {
    mode = "0644";
    text = ''
      [registries.search]
      registries = ['docker.io', 'quay.io']
    '';
  };

  # Creating images for funky architectures
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "armv6l-linux"
    "armv7l-linux"
    "mips64-linux"
    "mips64el-linux"
    "mips-linux"
    "mipsel-linux"
  ];
}
