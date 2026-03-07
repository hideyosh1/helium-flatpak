{
  description = "A Nix-flake-based Node.js development environment";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forEachSupportedSystem =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = import nixpkgs {
              inherit system;
              overlays = [ self.overlays.default ];
            };
          }
        );
    in
    {
      overlays.default = final: prev: rec {
        nodejs = prev.nodejs;
        yarn = prev.yarn.override { inherit nodejs; };
      };

      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.mkShell {

            venvDir = ".venv";
            packages =
              with pkgs;
              [
                node2nix
                nodejs
                yarn-berry
                nodePackages_latest.typescript-language-server
                typescript
                pyright
                black
                python313
              ]
              ++ (with pkgs.python313Packages; [
                pip
                venvShellHook
                requests

              ]);
            /*
              shellHook = ''
                npx update-browserslist-db@latest
              '';
            */
          };
        }
      );
    };
}
