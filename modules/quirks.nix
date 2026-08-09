{
  lib,
  pkgs,
  ...
}: {
  environment.variables = {
    GSK_RENDERER = lib.mkDefault "gl";
  };

  services.zram-generator = {
    enable = lib.mkDefault true;
    settings = {
      "zram0" = {
        "zram-size" = "ram*1.5";
        "compression-algorithm" = "zstd";
      };
    };
  };

  systemd.services = {
    "systemd-backlight@backlight:ktz8866-backlight" = {
      enable = false;
    };

    btrfs-grow-root = {
      description = "Expand BTRFS root filesystem to fill partition";
      wantedBy = ["multi-user.target"];
      after = ["local-fs.target"];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = ''
        STATE_FILE="/var/lib/nixos-btrfs-resized"

        if [ ! -f "$STATE_FILE" ]; then
          echo "State file not found. Resizing BTRFS root filesystem..."
          ${pkgs.btrfs-progs}/bin/btrfs filesystem resize max /

          if [ $? -eq 0 ]; then
            echo "Resize successful. Creating state file."
            mkdir -p /var/lib
            touch "$STATE_FILE"
          else
            echo "Failed to resize BTRFS filesystem."
            exit 1
          fi
        else
          echo "BTRFS root is already resized (state file exists). Skipping."
        fi
      '';
    };
  };
}
