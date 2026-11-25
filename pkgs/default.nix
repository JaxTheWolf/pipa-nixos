final: _prev: let
  pipaKernelVersion = "7.4.0-rc3";

  pipaKernelSrc = final.fetchFromGitLab {
    owner = "rmuxnet";
    repo = "linux";
    rev = "d0cd2c556f0b9d108b70c58f9b0951f859304aff";
    hash = "sha256-wfVQwDSlmNX1AteFUIr4GgJfM/FoeitQaZINPUbZN9g=";
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
