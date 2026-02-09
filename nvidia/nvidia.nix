# ~/nixos-config/nixosfiles/nvidia/nvidia.nix
#
# NVIDIA GPU configuration
# Uses the latest proprietary driver with modesetting enabled
#
{ config, pkgs, ... }:
{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = true;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };
}