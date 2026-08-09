{pkgs, ...}: {
  networking.hostName = "pipa";
  networking.networkmanager.enable = true;

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = false;
  };

  # Partition layout for Xiaomi Pad 6
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/NIX_BOOT";
      fsType = "vfat";
      options = ["fmask=0022" "dmask=0022"];
    };

    "/" = {
      device = "/dev/disk/by-label/NIX_ROOT";
      fsType = "btrfs";
      options = ["subvol=root" "compress=zstd" "noatime"];
    };

    "/nix" = {
      device = "/dev/disk/by-label/NIX_ROOT";
      fsType = "btrfs";
      options = ["subvol=nix" "compress=zstd" "noatime"];
      neededForBoot = true;
    };

    "/home" = {
      device = "/dev/disk/by-label/NIX_ROOT";
      fsType = "btrfs";
      options = ["subvol=home" "compress=zstd" "noatime"];
    };
  };

  # Default 'nixos' user account for image distribution
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "video" "audio" "input"];
    initialPassword = "nixos";
  };

  security.sudo.wheelNeedsPassword = false;

  # Touch-friendly desktop environment
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  environment.systemPackages = with pkgs; [
    git
    curl
    vim
    htop
    fastfetch
  ];

  system.stateVersion = "26.05";
}
