{
  lib,
  pkgs,
  ...
}: {
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="net", KERNEL=="wl*", RUN+="${pkgs.systemd}/bin/systemctl --no-block start bootmac-wlan.service"
  '';

  systemd.services = {
    "bootmac-wlan" = {
      description = "Apply MAC address for WLAN interface";
      restartIfChanged = false;
      stopIfChanged = false;

      serviceConfig = {
        Type = "oneshot";
        Environment = "PATH=${lib.makeBinPath [pkgs.coreutils pkgs.util-linux pkgs.gnugrep pkgs.gnused pkgs.iproute2]}";
      };

      script = ''
        set -e
        echo "WLAN hardware detection triggered by udev. Resolving current interface name..."

        timeout=5
        while [ $timeout -gt 0 ]; do
            IFACE=$(ls /sys/class/net/ 2>/dev/null | grep -E '^wl|^wlan' | head -n 1)
            if [ -n "$IFACE" ]; then break; fi
            sleep 1
            timeout=$((timeout - 1))
        done

        if [ -z "$IFACE" ]; then
            echo "Error: udev fired, but no wl/wlan interface found in /sys/class/net/" >&2
            exit 1
        fi

        echo "Active interface resolved to $IFACE. Extracting MAC..."

        mkdir -p /mnt/persist

        (
          flock -x 200
          mountpoint -q /mnt/persist || mount -o ro /dev/disk/by-partlabel/persist /mnt/persist

          if [ -f /mnt/persist/wlan/wlan_mac.bin ]; then
            RAW_MAC=$(grep -i "^wlan0=" /mnt/persist/wlan/wlan_mac.bin | cut -d'=' -f2)
            RAW_MAC=''${RAW_MAC//[$'\t\r\n ']}
            echo "$RAW_MAC" | sed 's/\(..\)/\1:/g; s/:$//' > /tmp/base_mac.txt
          fi

          umount /mnt/persist || true
        ) 200>/tmp/bootmac-mount.lock

        if [ -f /tmp/base_mac.txt ]; then
          MAC=$(cat /tmp/base_mac.txt)
          echo "Successfully extracted Base MAC: $MAC"

          WLAN_TIMEOUT=10
          timeout_wlan=0
          set +e
          while [ $timeout_wlan -lt $WLAN_TIMEOUT ]; do
              if ip link set dev "$IFACE" down && ip link set dev "$IFACE" address "$MAC"; then
                  ip link set dev "$IFACE" up
                  echo "WLAN MAC successfully updated on $IFACE."
                  break
              fi
              echo "Unable to set WLAN MAC on $IFACE, retrying..."
              sleep 1
              timeout_wlan=$((timeout_wlan + 1))
          done
        else
          echo "Error: /mnt/persist/wlan/wlan_mac.bin not found or extraction failed." >&2
        fi
      '';
    };

    "bootmac-bluetooth" = {
      description = "Initialize Qualcomm Bluetooth MAC securely before BlueZ wakes up";
      wantedBy = ["multi-user.target"];
      before = ["bluetooth.service"];
      after = ["bootmac-wlan.service"];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Environment = "PATH=${lib.makeBinPath [pkgs.coreutils pkgs.util-linux pkgs.gnugrep pkgs.gnused pkgs.bluez pkgs.iproute2]}";
      };

      script = ''
        echo "Pre-initializing Bluetooth hardware registers..."

        ip link set dev hci0 down 2>/dev/null || hciconfig hci0 down 2>/dev/null || true

        mkdir -p /mnt/persist
        mount -o ro /dev/disk/by-partlabel/persist /mnt/persist 2>/dev/null || true

        if [ -f /mnt/persist/wlan/wlan_mac.bin ]; then
          RAW_MAC=$(grep -i "^wlan0=" /mnt/persist/wlan/wlan_mac.bin | cut -d'=' -f2 | tr -d '\t\r\n ')
          MAC=$(echo "$RAW_MAC" | sed 's/\(..\)/\1:/g; s/:$//')

          PREFIX=''${MAC%:*}
          LAST_HEX=''${MAC##*:}
          LAST_DEC=$((16#$LAST_HEX + 1))
          NEW_LAST=$(printf "%02x" $((LAST_DEC % 256)))
          BT_MAC="$PREFIX:$NEW_LAST"

          echo "Baking Bluetooth MAC $BT_MAC into controller registers..."
          btmgmt -i 0 power off >/dev/null 2>&1 || true
          btmgmt -i 0 public-addr "$BT_MAC" >/dev/null 2>&1 || true
          btmgmt -i 0 power on >/dev/null 2>&1 || true
        fi

        umount /mnt/persist 2>/dev/null || true
        echo "Hardware initialization complete. Handing over to BlueZ."
      '';
    };
  };
}
