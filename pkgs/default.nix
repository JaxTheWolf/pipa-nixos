final: _prev: let
  pipaKernelVersion = "7.1.7";

  pipaKernelSrc = final.fetchFromGitHub {
    owner = "rr1111";
    repo = "linux-pipa";
    rev = "4e4b30b6533c498a2a87061e455330afa20dd3b6";
    hash = "sha256-B7FEK+AyDCs5m2X9yNiLwKoTsHhdUxUBkgImUn1bk/k=";
  };
in {
  pipa-firmware = final.callPackage ./firmware.nix {};

  pipa-kernel = final.callPackage ./kernel.nix {
    rawSrc = pipaKernelSrc;
    version = pipaKernelVersion;
  };

  pipa-headers = final.callPackage ./headers.nix {
    src = pipaKernelSrc;
    version = pipaKernelVersion;
  };

  qbootctl-pipa = final.callPackage ./qbootctl.nix {};

  build-pipa-images = final.callPackage ./build-images.nix {};
}
