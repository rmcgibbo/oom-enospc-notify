{ oom-enospc-notify }:
{ lib, pkgs, config, ... }:
with lib;
let cfg = config.services.oom-enospc-notify;
in {
  options.services.oom-enospc-notify = {
    enable = mkEnableOption "Kernel OOM / ENOSPC notifier";
    package = mkOption {
      type = types.package;
      default = oom-enospc-notify;
    };
  };
  config = mkIf cfg.enable {
    systemd.services.oom-enospc-notify = {
      enable = true;
      description = "Kernel OOM / ENOSPC notifier";

      wantedBy = [ "multi-user.target" ];
      after = [ "multi-user.target" ];
      requires = [ "network-online.target" ];

      serviceConfig = {
        ExecStart =
          "${pkgs.systemd}/bin/systemd-cat --priority info --stderr-priority err ${cfg.package}/bin/oom-enospc-notify";
        Restart = "on-failure";
        OOMScoreAdjust = -500;
      };
    };
  };
}
