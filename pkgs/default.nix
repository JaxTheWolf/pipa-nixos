final: _prev: let
  pipaKernelVersion = "7.1.7";

  pipaKernelSrc = final.fetchFromGitHub {
    owner = "rmuxnet";
    repo = "linux-7.xx";
    rev = "f6344729eb71c1cb0c4189827c679502f4cd85a8";
    hash = "sha256-5PMxfIWJ03xHrGlG8/g7pSf0LVAR2pmUsG2070oJXnw=";
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
