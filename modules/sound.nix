{pkgs, ...}: let
  pipa-ucm = pkgs.runCommand "pipa-ucm-conf" {} ''
    mkdir -p "$out/share/alsa/ucm2/conf.d/sm8250"
    mkdir -p "$out/share/alsa/ucm2/Qualcomm/sm8250"

    cp "${./audio-configs/Xiaomi_Pad_6.conf}" "$out/share/alsa/ucm2/conf.d/sm8250/Xiaomi_Pad_6.conf"
    cp "${./audio-configs/HiFi_pipa.conf}" "$out/share/alsa/ucm2/Qualcomm/sm8250/HiFi_pipa.conf"

    ln -s "Xiaomi_Pad_6.conf" "$out/share/alsa/ucm2/conf.d/sm8250/Xiaomi-Pad6-pipa-M82.conf"
  '';

  custom-alsa-ucm = pkgs.symlinkJoin {
    name = "alsa-ucm-merged";
    paths = [pipa-ucm pkgs.alsa-ucm-conf];
  };
in {
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  systemd.user.services.pipewire.environment.ALSA_CONFIG_UCM2 = "${custom-alsa-ucm}/share/alsa/ucm2";
  systemd.user.services.wireplumber.environment.ALSA_CONFIG_UCM2 = "${custom-alsa-ucm}/share/alsa/ucm2";

  environment.etc."wireplumber/wireplumber.conf.d/51-pipa.conf".source = ./audio-configs/51-pipa.conf;
}
