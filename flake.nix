# {
#   description = "Nixos config flake";

#   inputs = {
#     nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
#     # nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
#     stylix.url = "github:danth/stylix";
#     home-manager = {
#       url = "github:nix-community/home-manager/";
#       inputs.nixpkgs.follows = "nixpkgs";
#     };
#     sf-mono-liga-src = {
#    	 url = "github:shaunsingh/SFMono-Nerd-Font-Ligaturized";
#     	flake = false;
#   	};
#     sf-pro-src = {
#    	 url = "github:sahibjotsaggu/San-Francisco-Pro-Fonts";
#     	flake = false;
#   	};
#     #spicetify-nix.url = "github:the-argus/spicetify-nix";
#     vscode-server.url = "github:nix-community/nixos-vscode-server";
#   };

  

#   outputs = { self, nixpkgs, ...}@inputs:
#     let 
# 	    system = "x86_64-linux";
# 	    pkgs = nixpkgs.legacyPackages.${system};
#     in
#     {
    
#     nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
#       specialArgs = {inherit inputs;};
#       modules = [
# 	inputs.vscode-server.nixosModules.default
#         inputs.stylix.nixosModules.stylix
#         ./configuration.nix
# 	      inputs.home-manager.nixosModules.default
# 	];
#     };	
# #end of outputs
  		
# 	};
# }
{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    stylix.url = "github:danth/stylix";
    home-manager = {
      url = "github:nix-community/home-manager/";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sf-mono-liga-src = {
      url = "github:shaunsingh/SFMono-Nerd-Font-Ligaturized";
      flake = false;
    };
    sf-pro-src = {
      url = "github:sahibjotsaggu/San-Francisco-Pro-Fonts";
      flake = false;
    };
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    zen-browser = {
    url = "github:0xc000022070/zen-browser-flake";
    # IMPORTANT: we're using "libgbm" and is only available in unstable so ensure
    # to have it up-to-date or simply don't specify the nixpkgs input  
    inputs.nixpkgs.follows = "nixpkgs";
  };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";

      # Workaround overlay to revert the problematic onnxruntime commit
      myOverlay = final: prev: {
        pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
          (python-final: python-prev: {
            onnxruntime = python-prev.onnxruntime.overridePythonAttrs (oldAttrs: {
              buildInputs = final.lib.lists.remove final.onnxruntime oldAttrs.buildInputs;
            });
          })
        ];
      };

      # Import nixpkgs with our overlay and config applied
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ myOverlay ];
        config = {
          allowUnfree = true;
          cudaSupport = true;
        };
      };

      # NixOS modules to use
      modules = [
        inputs.vscode-server.nixosModules.default
        inputs.stylix.nixosModules.stylix
        ./configuration.nix
        inputs.home-manager.nixosModules.default
	({ config, pkgs, ... }: {
          services.vscode-server.enable = true;
        })
      ];
    in
    {
      # Define the desktop configuration
      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        inherit system modules;
        pkgs = pkgs;
        specialArgs = { inherit inputs; };
      };
    };
}
