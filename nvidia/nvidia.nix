{lib,pkgs,config,...}:
{
services.xserver.videoDrivers = ["nvidia"];
	hardware.nvidia = {
		modesetting.enable = true;
		nvidiaSettings = true;
		open=false;
		package = config.boot.kernelPackages.nvidiaPackages.stable;
	};
}