{ pkgs, lib, ... }: {
  # Configure the machine as a remote builder
  # Setting up the SSH keys is not done here
  users.users.nixremote = {
    isNormalUser = true;
    home = "/home/nixremote";
    description = "Unprivileged user for remote builds";
    group = "nogroup";
  };
  services.displayManager.hiddenUsers = [ "nixremote" ];

  # TODO: Conditionally add other hosts as remote builders (all except ourselves)

  nix.buildMachines = [{
    # Spline remote builder
    # remote-program cannot be passed as an option by itself, but can be put here as
    # it's just concatenated together internally:
    # https://github.com/NixOS/nixpkgs/blob/6a3ae7a5a12fb8cac2d59d7df7cbd95f9b2f0566/nixos/modules/config/nix-remote-build.nix#L32
    hostName = "vm-build-big?remote-program=/nix/var/nix/profiles/default/bin/nix-daemon";
    sshUser = "nixremote";
    systems = [ "x86_64-linux" "i686-linux" ];
    maxJobs = 2;
    speedFactor = 20;
    supportedFeatures = [ "benchmark" "big-parallel" ];
    mandatoryFeatures = [ ];
    protocol = "ssh-ng";
  }];
  nix.distributedBuilds = true;
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';
}
