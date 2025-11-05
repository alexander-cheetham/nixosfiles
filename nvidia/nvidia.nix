{lib,pkgs,config,inputs,...}:
{
services.xserver.videoDrivers = ["nvidia"];
	hardware.nvidia = {
		modesetting.enable = true;
		nvidiaSettings = true;
		open=false;
		package = config.boot.kernelPackages.nvidiaPackages.latest;
		# package = config.boot.kernelPackages.nvidiaPackages.stable;
		# package = config.boot.kernelPackages.nvidiaPackages.beta; #: github repo for details
		# 560: https://github.com/NixOS/nixpkgs/pull/329450
		# package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
  	# 					version = "560.28.03";
		# 					sha256_64bit = "sha256-martv18vngYBJw1IFUCAaYr+uc65KtlHAMdLMdtQJ+Y=";
		# 					sha256_aarch64 = "sha256-+u0ZolZcZoej4nqPGmZn5qpyynLvu2QSm9Rd3wLdDmM=";
		# 					openSha256 = "sha256-asGpqOpU0tIO9QqceA8XRn5L27OiBFuI9RZ1NjSVwaM=";
		# 					settingsSha256 = "sha256-b4nhUMCzZc3VANnNb0rmcEH6H7SK2D5eZIplgPV59c8=";
		# 					persistencedSha256 = "sha256-MhITuC8tH/IPhCOUm60SrPOldOpitk78mH0rg+egkTE=";
		# 				};
		# package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
		# 				version = "560.35.03";
		# 				sha256_64bit = "sha256-8pMskvrdQ8WyNBvkU/xPc/CtcYXCa7ekP73oGuKfH+M=";
		# 				sha256_aarch64 = lib.fakeSha256;
		# 				openSha256 = "sha256-/32Zf0dKrofTmPZ3Ratw4vDM7B+OgpC4p7s+RHUjCrg=";
		# 				settingsSha256 = "sha256-ZpuVZybW6CFN/gz9rx+UJvQ715FZnAOYfHn5jt5Z2C8=";
		# 				persistencedSha256 = lib.fakeSha256;

		# 			};
	};
}