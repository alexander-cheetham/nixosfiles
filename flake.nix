{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    stylix.url = "github:danth/stylix";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sf-mono-liga-src = {
   	 url = "github:shaunsingh/SFMono-Nerd-Font-Ligaturized";
    	flake = false;
  	};
  };

  outputs = { self, nixpkgs, ...}@inputs:
    let 
	system = "x86_64-linux";
	pkgs = nixpkgs.legacyPackages.${system};
    in
    {

    nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        inputs.stylix.nixosModules.stylix
        ./nixosfiles/stylix/stylix.nix
        ./configuration.nix
	 inputs.home-manager.nixosModules.default
	];
    };	
#end of outputs
  		
	};
}
