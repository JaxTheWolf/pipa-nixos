{...}: {
  imports = [
    ./hardware.nix
    ./bootmac.nix
    ./gdm-monitors.nix
    ./packages.nix
    ./qbootctl.nix
    ./quirks.nix
    ./sound.nix
  ];
}
