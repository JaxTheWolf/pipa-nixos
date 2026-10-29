final: _prev: let
  pipaKernelVersion = "7.3.0";

  pipaKernelSrc = final.fetchFromGitHub {
    owner = "JaxTheWolf";
    repo = "linux-pipa";
    rev = "8fee1e950cb71306f414c889335799c0bfca526c";
    hash = "sha256-dklKVSYHBZ7DWcu4U3Q7+jdHjztL428wNHeISoLH54U=";
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
