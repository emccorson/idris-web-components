{
  description = "Custom Elements for the web in Idris";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
    let
      pkgs = import nixpkgs { inherit system; };
    in
      {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            idris2
            gnumake
          ];
        };
      }
    );
}
