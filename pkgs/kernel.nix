{
  lib,
  buildLinux,
  runCommand,
  rawSrc,
  version,
  ...
} @ args: let
  patchedSrc = runCommand "linux-src-pipa" {} ''
    cp -a ${rawSrc} $out
    chmod -R +w $out

    cp ${./pipa.config} $out/arch/arm64/configs/pipa.config
    patchShebangs $out
  '';
in
  buildLinux (args
    // {
      inherit version;
      modDirVersion = version;
      src = patchedSrc;
      defconfig = "pipa.config";
      ignoreConfigErrors = true;
      enableCommonConfig = false;
      stripDebugList = ["vmlinux" "lib/modules"];

      structuredExtraConfig = with lib.kernel; {
        ARCH_ACTIONS = no;
        ARCH_SUNXI = no;
        ARCH_AMLOGIC = no;
        ARCH_APPLE = no;
        ARCH_BCM = no;
        ARCH_BRCMSTB = no;
        ARCH_EXYNOS = no;
        ARCH_HISILICON = no;
        ARCH_MEDIATEK = no;
        ARCH_RENESAS = no;
        ARCH_ROCKCHIP = no;
        ARCH_TEGRA = no;
        ARCH_SPRD = no;

        HISILICON_ERRATUM_161600802 = no;
        HISILICON_ERRATUM_161010101 = no;

        DRM_AMDGPU = no;
        DRM_NOUVEAU = no;
        DRM_RADEON = no;
        DRM_I915 = no;
        DRM_EXYNOS = no;
        DRM_HISI = no;
        DRM_MEDIATEK = no;
        DRM_ROCKCHIP = no;
        DRM_TEGRA = no;
        DRM_SUN4I = no;
        DRM_PANFROST = no;
        DRM_LIMA = no;
        DRM_V3D = no;
        DRM_VC4 = no;

        SND_SOC_SAMSUNG = no;
        SND_SOC_MEDIATEK = no;
        SND_SOC_ROCKCHIP = no;
        SND_SOC_AMD_ACP = no;

        NET_VENDOR_HISILICON = no;
        WLAN_VENDOR_ADMTEK = no;
        WLAN_VENDOR_ATMEL = no;
        WLAN_VENDOR_BROADCOM = no;
        WLAN_VENDOR_INTEL = no;
        WLAN_VENDOR_INTERSIL = no;
        WLAN_VENDOR_MARVELL = no;
        WLAN_VENDOR_MEDIATEK = no;
        WLAN_VENDOR_MICROCHIP = no;
        WLAN_VENDOR_PURELIFI = no;
        WLAN_VENDOR_RALINK = no;
        WLAN_VENDOR_REALTEK = no;
        WLAN_VENDOR_RSI = no;
        WLAN_VENDOR_SILABS = no;
        WLAN_VENDOR_ST = no;
        WLAN_VENDOR_TI = no;
        WLAN_VENDOR_ZYDAS = no;
        WLAN_VENDOR_QUANTENNA = no;

        NET_VENDOR_AMAZON = no;
        NET_VENDOR_CAVIUM = no;
        NET_VENDOR_CHELSIO = no;
        NET_VENDOR_INTEL = no;
        NET_VENDOR_MELLANOX = no;
        NET_VENDOR_MICROSOFT = no;
        NET_VENDOR_PENSANDO = no;
        NET_VENDOR_SOLARFLARE = no;
        NET_VENDOR_AMD = no;

        XEN = no;
        XEN_DOM0 = no;
        XEN_BALLOON = no;
        XEN_SCRUB_PAGES_DEFAULT = no;
        XEN_DEV_EVTCHN = no;
        XEN_BACKEND = no;
        XENFS = no;
        XEN_COMPAT_XENFS = no;
        XEN_SYS_HYPERVISOR = no;
        XEN_XENBUS_FRONTEND = no;
        XEN_GNTDEV = no;
        XEN_GRANT_DEV_ALLOC = no;
        XEN_PCI_STUB = no;
        XEN_PCIDEV_STUB = no;
        XEN_PRIVCMD = no;
        XEN_EFI = no;
        XEN_AUTO_XLATE = no;
        XEN_BLKDEV_FRONTEND = no;
        XEN_NETDEV_FRONTEND = no;
        XEN_FBDEV_FRONTEND = no;

        KVM = no;
        KVM_COMMON = no;
        KVM_MMIO = no;
        KVM_VFIO = no;
        KVM_GENERIC_DIRTYLOG_READ_PROTECT = no;
        KVM_GENERIC_HARDWARE_ENABLING = no;
        KVM_GUEST_MEMFD = no;

        INFINIBAND = no;
        INFINIBAND_USER_ACCESS = no;
        FPGA = no;
        THUNDERBOLT = no;
        COMEDI = no;
        GNSS = no;
        MOST = no;

        DEBUG_INFO = no;
        DEBUG_INFO_REDUCED = no;
        DEBUG_INFO_COMPRESSED = no;
        DEBUG_KERNEL = no;
        RUNTIME_TESTING_MENU = no;
      };

      extraMeta.branch = lib.versions.majorMinor version;
    })
