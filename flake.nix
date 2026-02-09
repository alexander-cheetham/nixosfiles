# ~/nixos-config/flake.nix
#
# NixOS Flake Configuration for Desktop Workstation
#
# This flake manages:
# - NixOS system configuration (desktop)
# - Home Manager user configuration (ac)
# - Custom overlays for font packages and package overrides
#
# Usage:
#   sudo nixos-rebuild switch --flake .#desktop
#
# Inputs:
#   - nixpkgs: NixOS unstable channel
#   - home-manager: User environment management
#   - stylix: Theming across applications
#   - zen-browser: Custom browser flake
#   - vscode-server: VSCode remote development
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
      # IMPORTANT: we're using "libgbm" and is only available in unstable
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";

      # Consolidated overlay for all customizations
      myOverlay = final: prev: {
        # Python package overrides for compatibility
        python3Packages = prev.python3Packages.overrideScope (self: super:
          let
            promptToolkitVersion = "3.0.52";
          in {
            onnxruntime = super.onnxruntime.overridePythonAttrs (oldAttrs: {
              buildInputs = final.lib.lists.remove final.onnxruntime oldAttrs.buildInputs;
            });
            prompt-toolkit = super.prompt-toolkit.overridePythonAttrs (_: {
              version = promptToolkitVersion;
              src = prev.fetchFromGitHub {
                owner = "prompt-toolkit";
                repo = "python-prompt-toolkit";
                rev = "refs/tags/${promptToolkitVersion}";
                hash = "sha256-ggCy7xTvOkjy6DgsO/rPNtQiAQ4FjsK4ShrvkIHioNQ=";
              };
              postPatch = ''
                # https://github.com/prompt-toolkit/python-prompt-toolkit/issues/1988
                substituteInPlace src/prompt_toolkit/__init__.py \
                  --replace-fail 'metadata.version("prompt_toolkit")' '"${promptToolkitVersion}"'
              '';
            });
          });

        # Custom font packages
        sf-mono-liga-bin = prev.stdenvNoCC.mkDerivation {
          pname = "sf-mono-liga-bin";
          version = "dev";
          src = inputs.sf-mono-liga-src;
          dontConfigure = true;
          installPhase = ''
            mkdir -p $out/share/fonts/opentype
            cp -R $src/*.otf $out/share/fonts/opentype/
          '';
        };

        sf-pro-bin = prev.stdenvNoCC.mkDerivation {
          pname = "sf-pro-bin";
          version = "dev";
          src = inputs.sf-pro-src;
          dontConfigure = true;
          installPhase = ''
            mkdir -p $out/share/fonts/opentype
            cp -R $src/*.otf $out/share/fonts/opentype/
          '';
        };

        # Waybar with experimental features enabled
        waybar = prev.waybar.overrideAttrs (oldAttrs: {
          mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
        });
      };

      # NixOS modules to use
      modules = [
        ({ ... }: {
          nixpkgs.overlays = [ myOverlay ];
          nixpkgs.config = {
            allowUnfree = true;
            cudaSupport = true;
          };
        })
        inputs.vscode-server.nixosModules.default
        inputs.stylix.nixosModules.stylix
        ./configuration.nix
        inputs.home-manager.nixosModules.default
        ({ ... }: {
          services.vscode-server.enable = true;
        })
      ];
    in
    {
      # Define the desktop configuration
      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        inherit system modules;
        specialArgs = { inherit inputs; };
      };
    };
}
