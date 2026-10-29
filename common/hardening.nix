{ ... }:
{
  environment.memoryAllocator.provider = "graphene-hardened";

  boot.blacklistedKernelModules = [
    # Obscure network protocols
    "ax25"
    "netrom"
    "rose"

    # Old or rare or insufficiently audited filesystems
    "adfs"
    "affs"
    "bfs"
    "befs"
    "cramfs"
    "efs"
    "erofs"
    "exofs"
    "freevxfs"
    "f2fs"
    "hfs"
    "hpfs"
    "jfs"
    "minix"
    "nilfs2"
    "omfs"
    "qnx4"
    "qnx6"
    "sysv"
    "ufs"
  ];

  nix.settings.allowed-users = [ "@wheel" ];

  boot.kernel.sysctl = {
    "kernel.kptr_restrict" = "2";
    "kernel.unprivileged_bpf_disabled" = 1;
    "net.core.bpf_jit_harden" = 2;
    "kernel.io_uring_disabled" = 2;
    "kernel.unprivileged_userns_clone" = 1;
  };
}
