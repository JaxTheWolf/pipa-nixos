{
  lib,
  linuxManualConfig,
  runCommand,
  rawSrc,
  version,
  ...
}: let
  patchedSrc = runCommand "linux-src-pipa" {} ''
    cp -a ${rawSrc} $out
    chmod -R +w $out
    patchShebangs $out

    # Inject missing GPIO consumer and hex helper headers into nanosic_803.c
    sed -i '/#include <linux\/i2c.h>/a #include <linux\/gpio\/consumer.h>\n#include <linux\/hex.h>' \
      $out/drivers/input/keyboard/nanosic_803.c
  '';
in
  linuxManualConfig {
    inherit version;
    modDirVersion = version;
    src = patchedSrc;
    configfile = ./pipa.config;
    features.efiBootStub = true;

    extraMeta.branch = lib.versions.majorMinor version;
  }
