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
        "hid_generic"
        "icc_osm_l3"
        "msm"
        "nanosic_803"
        "panel_novatek_nt36532"
        "phy_qcom_qmp_pcie"
        "phy_qcom_qmp_ufs"
        "pinctrl_sm8250"
        "ufs_qcom"
        "ufshcd_core"
        "ufshcd_pltfrm"
        "usb_storage"
        "usbhid"
      ];

      extraFirmwarePaths = [
        "novatek/nt36532_csot.bin"
        "novatek/nt36532_tianma.bin"
        "qcom/a650_gmu.bin"
        "qcom/a650_sqe.fw"
        "qcom/a650_zap.mbn"
      ];

      includeDefaultModules = false;
      allowMissingModules = true;
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
