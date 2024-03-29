{ config, lib, pkgs, ... }: {
  imports = [ ../roles/homeserver.nix ../hardware/t400.nix ];

  system.stateVersion = "23.05";

  # Use the GRUB 2 boot loader, because systemd doesn't support legacy BIOS
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.efiSupport = false;
  boot.loader.grub.configurationLimit = 50;

  # It's a laptop
  services.logind.lidSwitch = "ignore";

  networking.interfaces.enp0s25.useDHCP = true;
  networking.interfaces.wlp3s0.useDHCP = true;
  networking.interfaces.wwp0s20u4i6.useDHCP = true;

  networking.hostName = "t400-homeserver";
  networking.hostId = "35c1d661";

  # See https://grahamc.com/blog/erase-your-darlings for rationale behind this setup

  # / is wiped on every boot to keep unmanaged state under control
  fileSystems."/" = {
    device = "rpool/expendable/wipedonboot";
    fsType = "zfs";
  };

  fileSystems."/nix" = {
    device = "rpool/expendable/nix";
    fsType = "zfs";
  };

  # This is where precious system state outside /home is stored
  fileSystems."/persist" = {
    device = "rpool/precious/systempersist";
    fsType = "zfs";
  };

  fileSystems."/home" = {
    device = "rpool/precious/home";
    fsType = "zfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/5503d76e-dccf-4b6d-abaa-d0817e8c01cb";
    fsType = "ext4";
  };

  # ZFS storage for various kinds of mass media
  fileSystems."/tank/torrents" = {
    device = "tank/torrents";
    fsType = "zfs";
  };

  # Remember connected networks and their creds
  # TODO: Replace w/ server solution
  environment.etc."NetworkManager/system-connections" = {
    source = "/persist/etc/NetworkManager/system-connections/";
  };

  # Remember NixOS configuration
  environment.etc."nixos" = { source = "/persist/etc/nixos/"; };

  # Remember user credentials
  environment.etc."passwd" = { source = "/persist/etc/passwd"; };
  environment.etc."passwd-" = { source = "/persist/etc/passwd-"; };
  environment.etc."shadow" = { source = "/persist/etc/shadow"; };
  environment.etc."shadow-" = { source = "/persist/etc/shadow-"; };

  # Remember ddclient secrets
  environment.etc."ddclient.conf" = { source = "/persist/etc/ddclient.conf"; };

  # For services where state location can't be changed in the config, we use symlinks
  systemd.tmpfiles.rules = [
    # Remember LXD containers
    "L /var/lib/lxd - - - - /persist/var/lib/lxd"
    # Remember docker containers
    "L /var/lib/docker - - - - /persist/var/lib/docker"
    # Remember libvirt VMs
    "L /var/lib/libvirt - - - - /persist/var/lib/libvirt"
    # Remember root's home (needed to keep system channels)
    "L /root - - - - /persist/root"
    # Remember users who completed the sudo lecture so it doesn't repeat after every boot
    "L /var/db/sudo/lectured - - - - /persist/var/db/sudo/lectured"
    # Remember private key and other data for tor SSH hidden service
    "L /var/lib/torssh - - - - /persist/var/lib/torssh"
  ];

  # Remember SSH host keys
  services.openssh = {
    hostKeys = [
      {
        path = "/persist/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/persist/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];
  };

  # Add ZFS support
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.requestEncryptionCredentials = true;
  boot.zfs.extraPools = [ "tank" ];
  # ZFS services
  services.zfs.autoSnapshot.enable = true;
  # ZFS scrubbing, but only on AC power
  services.zfs.autoScrub.enable = true;
  systemd.services.zfs-scrub.unitConfig.ConditionACPower = true;
  # ZFS trim, but also only on AC
  services.zfs.trim.enable = true;
  systemd.services.zpool-trim.unitConfig.ConditionACPower = true;

  # Allegedly, ZFS does not like the kernel scheduler messing with it
  # TODO: Research how to set this only for /dev/sda
  boot.kernelParams = [ "elevator=none" ];

  # Allow remote unlock of root via SSH
  networking.useDHCP = true; # Deprecated, but needed according to wiki
  boot = {
    initrd.postDeviceCommands = lib.mkAfter ''
      zfs rollback -r rpool/expendable/wipedonboot@blank
    '';
    initrd.network = {
      # This will use udhcp to get an ip address.
      # Make sure you have added the kernel module for your network driver to `boot.initrd.availableKernelModules`,
      # so your initrd can load it!
      # Static ip addresses might be configured using the ip argument in kernel command line:
      # https://www.kernel.org/doc/Documentation/filesystems/nfs/nfsroot.txt
      enable = true;
      ssh = {
        enable = true;
        port = 222;
        # These are copied into the store, but aren't *that* sensitive
        # They have to be generated manually.
        hostKeys = [
          "/persist/etc/initrd-ssh-key-rsa"
          "/persist/etc/initrd-ssh-key-dss"
          "/persist/etc/initrd-ssh-key-ecdsa"
        ];
        # All users being a member of the "wheel" group are allowed to connect and enter the password.
        authorizedKeys = with lib;
          concatLists (mapAttrsToList (name: user:
            if elem "wheel" user.extraGroups then
              user.openssh.authorizedKeys.keys
            else
              [ ]) config.users.users);
      };
      # this will automatically load the zfs password prompt on login
      # and kill the other prompt so boot can continue
      postCommands = ''
        echo "zfs load-key -a; killall zfs" >> /root/.profile
      '';
    };
  };
}
