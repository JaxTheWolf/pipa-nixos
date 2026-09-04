final: _prev: let
  pipaKernelVersion = "7.1.7";

  pipaKernelSrc = final.fetchFromGitLab {
    owner = "rmuxnet";
    repo = "linux";
    rev = "b8c2279dd1fff1a78f013a7620693993564cabe7";
    hash = "sha256-jgZEi3KeBU4gGQpUy1MR2tdG60WxIo4puB0AZg6DFes=";
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
