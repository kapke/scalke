{
  description = "A playground for Scala.js and nix flakes";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    let
      system = "x86_64-darwin";
      pkgs = import nixpkgs { inherit system; };
      inherit (pkgs) stdenv lib;
      nodejs = lib.customisation.overrideDerivation pkgs.nodejs-16_x
        (prev:
          let postInstall = prev.postInstall + "corepack enable;";
          in (prev // { postInstall = postInstall; })
        );
      yarn = pkgs.yarn.override {
        inherit nodejs;
      };
      lernaBuilt =
        stdenv.mkDerivation {
          name = "lerna_built";
          src = self;
          buildInputs = [ nodejs yarn ];
          buildPhase = ''
            node --version;
            yarn --version;
            //yarn install;
            //yarn run build'';
        };
      packageNames = ''
        npx lerna list --loglevel warn
      '';
    in
    rec {
      packages.${system}.aref = lernaBuilt;
      defaultPackage.${system} = packages.${system}.aref;
    };
}
