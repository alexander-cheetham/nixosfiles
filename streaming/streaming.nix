# ~/nixos-config/nixosfiles/streaming/streaming.nix
#
# Sunshine game streaming configuration
# Opens required firewall ports and sets up capabilities for sunshine
#
{ config, pkgs, ... }:
let
  sunshineOverride = pkgs.sunshine.override { cudaSupport = true; };
in
{
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 47984 47989 47990 48010 ];
    allowedUDPPortRanges = [
      { from = 47998; to = 48000; }
      { from = 8000; to = 8010; }
    ];
  };

  security.wrappers.sunshine = {
    owner = "root";
    group = "root";
    capabilities = "cap_sys_admin+p";
    source = "${sunshineOverride}/bin/sunshine";
  };
}