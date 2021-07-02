{ nix, ... }: {
  nix.buildMachines = [{
    hostName = "builder";
    systems = [ "x86_64-linux" ];
    maxJobs = 10;
    speedFactor = 10;
    supportedFeatures = [ "benchmark" "big-parallel" ];
    mandatoryFeatures = [ ];
  }];
  nix.distributedBuilds = true;
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';
}
