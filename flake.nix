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
        # TODO: how do I make this a parameter you pass into the flake?
        linuxPackages = pkgs.linuxPackages_latest;
      in rec {
        packages.oom-enospc-notify = pkgs.stdenv.mkDerivation rec {
          pname = "oom-enospc-notify";
          version = "0.1-${linuxPackages.kernel.version}";

          src = ./.;
          nativeBuildInputs = [ pkgs.python3.pkgs.wrapPython ];
          propagatedBuildInputs = [ linuxPackages.bcc ] ++ (with pkgs; [ kmod toybox bzip2 ]);

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

        defaultPackage = packages.oom-enospc-notify;

        nixosModules.oom-enospc-notify = { lib, pkgs, config, ... }:
          with lib;
          let cfg = config.services.oom-enospc-notify;
          in {
            options.services.oom-enospc-notify = {
              enable = mkEnableOption "Kernel OOM / ENOSPC notifier";
            };
            config = mkIf cfg.enable {
              systemd.services.oom-enospc-notify = {
                enable = true;
                description = "Kernel OOM / ENOSPC notifier";

                wantedBy = [ "multi-user.target" ];
                after = [ "multi-user.target" ];
                requires = [ "network-online.target" ];

                serviceConfig = {
                  ExecStart = "${pkgs.systemd}/bin/systemd-cat --priority info --stderr-priority err ${defaultPackage}/bin/oom-enospc-notify";
                  Restart = "on-failure";
                  OOMScoreAdjust = -500;
                };
              };
            };
          };
      });
}
