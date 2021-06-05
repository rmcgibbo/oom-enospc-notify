{
  description = "Kernel OOM / ENOSPC notifier";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        lib = { linuxPackages }:
          pkgs.stdenv.mkDerivation rec {
            pname = "oom-enospc-notify";
            version = "0.1-${linuxPackages.kernel.version}";

            src = ./.;
            nativeBuildInputs = [ pkgs.python3.pkgs.wrapPython ];
            propagatedBuildInputs = [ linuxPackages.bcc ]
              ++ (with pkgs; [ kmod toybox bzip2 ]);

            installPhase = ''
              runHook preInstall
              mkdir -p $out/bin
              install oom-enospc-notify $out/bin/
              runHook postInstall
            '';
            postFixup = ''
              wrapPythonPrograms
            '';
          };
          oom-enospc-notify = lib {linuxPackages = pkgs.linuxPackages_latest; };
      in {
        lib = lib;
        packages.oom-enospc-notify = oom-enospc-notify;
        defaultPackage = oom-enospc-notify;
        nixosModules.oom-enospc-notify = (import ./module.nix) { inherit oom-enospc-notify; };
      });
}
