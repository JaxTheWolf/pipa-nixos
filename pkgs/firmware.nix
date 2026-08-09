{
  stdenvNoCC,
  fetchFromGitea,
}:
stdenvNoCC.mkDerivation {
  pname = "xiaomi-pipa-firmware";
  version = "1.1-2";

  src = fetchFromGitea {
    domain = "gt.awroo.fun";
    owner = "romanl";
    repo = "xiaomi-pipa-firmware";
    rev = "842d35beffeda8c6d1b0e611b335543bf0e6b41e";
    hash = "sha256-NPApyQVkcDXcxNh1AK863r6VQGP4VQMapoFgHYni8fA=";
  };

  installPhase = ''
    runHook preInstall

    if [ -d "lib/firmware/nuvolta" ]; then
      mkdir -p $out/lib/firmware/awinic
      cp -a lib/firmware/awinic/* $out/lib/firmware/awinic/
    fi

    if [ -d "lib/firmware/nuvolta" ]; then
      mkdir -p $out/lib/firmware/novatek
      cp -a lib/firmware/novatek/* $out/lib/firmware/novatek/
    fi

    if [ -d "lib/firmware/nuvolta" ]; then
      mkdir -p $out/lib/firmware/nuvolta
      cp -a lib/firmware/nuvolta/* $out/lib/firmware/nuvolta/
    fi

    mkdir -p $out/lib/firmware/qcom
    cp -a lib/firmware/sm8250 $out/lib/firmware/qcom/

    mkdir -p $out/share
    cp -a usr/share/qcom $out/share/

    runHook postInstall
  '';
}
