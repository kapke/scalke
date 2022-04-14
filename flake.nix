{
  description = "A playground for Scala.js and nix flakes";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable"; #because of node2nix, 1.10 supports node.js 16
    flake-utils.url = "github:numtide/flake-utils";
    sbt-derivation = {
      type = "github";
      owner = "zaninime";
      repo = "sbt-derivation";
    };
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, flake-utils, sbt-derivation }:
    let
      system = "x86_64-darwin";
      pkgs = import nixpkgs { inherit system; overlays = [ sbt-derivation.overlay ]; };
      pkgsUnstable = import nixpkgs-unstable { inherit system; };
      inherit (pkgs) stdenv lib nodejs-16_x exa;
      baseNode = nodejs-16_x;
      npmGlobalsNix = stdenv.mkDerivation {
        name = "nodejs-corepack";
        srcs = self;
        buildInputs = [ pkgsUnstable.nodePackages.node2nix exa pkgs.jq ];
        buildPhase = ''
          node2nix --help
          exa -laT -L 2 --git .
          mkdir $out
          echo "node2nix --input global-packages.json --output $out/globalPackages.nix"
          cat package.json | jq '.dependencies |= []' > fake-package.json
          node2nix --input fake-package.json --supplement-input global-packages.json --output $out/globalPackages.nix --node-env $out/nodeEnv.nix
          exa -laT -L 2 --git $out
        '';
        installPhase = ''
          true
        '';
        inherit baseNode;
      };
      npmGlobalsInstalled = lib.trivial.pipe [ "globalPackages" "nodeEnv" ] [
        (builtins.map (name: lib.attrsets.nameValuePair name (npmGlobalsNix + "/" + name + ".nix")))
        (builtins.listToAttrs)
        (prev: import (prev.globalPackages) {
          nodeEnv = import prev.nodeEnv {
            nodejs = baseNode;
            python2 = pkgs.python2Full;
            inherit lib stdenv pkgs;
            inherit (pkgs) libtool runCommand writeTextFile writeShellScript;
          };
          nix-gitignore = {
            gitignoreSourcePure = (input1: input2: self);
          };
          inherit stdenv lib;
          inherit (pkgs) fetchurl fetchgit;
        })
        (lib.debug.traceValFn (builtins.attrNames))
      ];
      corepackEnabled = stdenv.mkDerivation {
        name = "corepack_enabled";
        src = self;
        buildInputs = [ baseNode npmGlobalsInstalled.nodeDependencies exa pkgs.yq-go ];
        buildPhase = ''
          bin=$out/bin
          mkdir -p $bin
          yq --help
          yarnPath=`yq e '.yarnPath' .yarnrc.yml`
          echo $yarnPath
          chmod +x $yarnPath
          cp $yarnPath $bin/yarn
          exa -laT -L 2 --git $out
          #chmod +x $bin/yarn
          #corepack --help;
          #corepack enable --help;
          echo $out;
          #corepack enable yarn --install-directory $bin;
          exa -laT -L 2 --git $out
        '';
        installPhase = "exa -laT -L 2 --git $out";
        inherit baseNode;
        inherit (npmGlobalsInstalled) nodeDependencies;
      };
      lernaBuilt =
        stdenv.mkDerivation
          {
            name = "lerna_built";
            src = self;
            buildInputs = [ baseNode corepackEnabled exa pkgs.sbt ];
            buildPhase = ''
              node --version;
              corepack --version;
              echo $corepackEnabled
              exa -laT -L 2 --git $corepackEnabled
              $corepackEnabled/bin/yarn --version;
              yarn config set enableNetwork false
              yarn config set enableTelemetry false
              yarn install --immutable --immutable-cache;
              yarn config unset enableNetwork
              yarn run build'';
            inherit baseNode corepackEnabled;
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
