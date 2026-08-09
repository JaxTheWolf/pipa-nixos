final: _prev: let
  pipaKernelVersion = "7.1.7";

  pipaKernelSrc = final.fetchFromGitHub {
    owner = "rmuxnet";
    repo = "linux";
    rev = "8205db9b0e34f9be5064c9244cc5ad94c4aca9a6";
    hash = "sha256-fPHSVS+47QlhMM7s74JzBDZIRH4NOHKkKTpL4xU50NA=";
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
