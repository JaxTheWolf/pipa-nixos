{
  lib,
  pkgs,
  ...
}: {
  nixpkgs.overlays = [
    (import ../pkgs)
  ];

  boot = {
    initrd = {
      availableKernelModules = [
        "panel_novatek_nt36532"
        "msm"
        "nanosic_803"
        "usbhid"
        "pinctrl_sm8250"
        "ufs_qcom"
        "ufshcd_core"
        "ufshcd_pltfrm"
        "icc_osm_l3"
        "phy_qcom_qmp_ufs"
        "phy_qcom_qmp_pcie"
      ];

      extraFirmwarePaths = [
        "novatek/nt36532_tianma.bin"
        "novatek/nt36532_csot.bin"
        "qcom/a650_sqe.fw"
        "qcom/a650_gmu.bin"
        "qcom/a650_zap.mbn"
      ];
    };

    kernelParams = [
      "console=tty0"
      "fbcon=rotate:1"
      "rootwait"
    ];

    kernelPackages = lib.mkDefault (pkgs.linuxPackagesFor pkgs.pipa-kernel);
  };

  hardware = {
    firmware = [
      pkgs.pipa-firmware
    ];

    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        libva
        libva-utils
      ];
    };

    enableRedistributableFirmware = lib.mkDefault true;
    deviceTree.name = lib.mkDefault "qcom/sm8250-xiaomi-pipa.dtb";
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";

  environment.variables = {
    SYSTEMD_RELAX_ESP_CHECKS = "1";
  };

  security.sudo.extraConfig = ''
    Defaults env_keep += "SYSTEMD_RELAX_ESP_CHECKS"
  '';
}
