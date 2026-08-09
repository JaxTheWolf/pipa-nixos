{
  pkgs,
  toplevel,
  ...
}:
pkgs.writeShellApplication {
  name = "build-pipa-images";

  runtimeInputs = with pkgs; [
    coreutils
    util-linux
    dosfstools
    btrfs-progs
    git
    nixos-install-tools
    nix
    jq
    android-tools
  ];

  text = ''
    set -e
    MNT_DIR="$PWD/mnt"
    OUT_DIR="$PWD/images"

    echo "=> Creating output directories..."
    mkdir -p "$OUT_DIR"
    mkdir -p "$MNT_DIR"

    cleanup() {
      echo "=> Ensuring mounts are released..."
      sync
      sudo umount "$MNT_DIR/boot" 2>/dev/null || true
      sudo umount "$MNT_DIR/nix" 2>/dev/null || true
      sudo umount "$MNT_DIR/home" 2>/dev/null || true
      sudo umount "$MNT_DIR" 2>/dev/null || true
    }
    trap cleanup EXIT

    echo "=> Wiping old images..."
    rm -f "$OUT_DIR/boot.img" "$OUT_DIR/rootfs.img" "$OUT_DIR/rootfs.sparse.img"

    echo "=> Calculating dynamic RootFS size..."
    CLOSURE_BYTES=$(nix path-info --json -S "${toplevel}" | jq -r '.[].closureSize')

    MARGIN_BYTES=$(( 512 * 1024 * 1024 ))
    ROOTFS_BYTES=$(( CLOSURE_BYTES + MARGIN_BYTES ))

    CLOSURE_MB=$(( CLOSURE_BYTES / 1024 / 1024 ))
    ROOTFS_MB=$(( ROOTFS_BYTES / 1024 / 1024 ))

    echo "   System closure size: ''${CLOSURE_MB} MB"
    echo "   Target RootFS size:  ''${ROOTFS_MB} MB"

    echo "=> Allocating blocks..."
    fallocate -l 1G "$OUT_DIR/boot.img"
    truncate -s "$ROOTFS_BYTES" "$OUT_DIR/rootfs.img"

    echo "=> Formatting images natively..."
    mkfs.vfat -S 4096 -F 32 -n NIX_BOOT "$OUT_DIR/boot.img"
    mkfs.btrfs --sectorsize 4096 -L NIX_ROOT "$OUT_DIR/rootfs.img" -f

    echo "=> Creating Btrfs subvolumes..."
    sudo mount -t btrfs "$OUT_DIR/rootfs.img" "$MNT_DIR"
    sudo btrfs subvolume create "$MNT_DIR/root"
    sudo btrfs subvolume create "$MNT_DIR/nix"
    sudo btrfs subvolume create "$MNT_DIR/home"
    sudo umount "$MNT_DIR"

    echo "=> Mounting images in Btrfs sequence..."
    sudo mount -o subvol=root,compress=zstd:9 "$OUT_DIR/rootfs.img" "$MNT_DIR"

    sudo mkdir -p "$MNT_DIR/boot" "$MNT_DIR/nix" "$MNT_DIR/home"

    sudo mount -o subvol=nix,compress=zstd:9 "$OUT_DIR/rootfs.img" "$MNT_DIR/nix"
    sudo mount -o subvol=home,compress=zstd:9 "$OUT_DIR/rootfs.img" "$MNT_DIR/home"
    sudo mount "$OUT_DIR/boot.img" "$MNT_DIR/boot"

    echo "=> Injecting the ARM64 OS and native Bootloader..."
    sudo SYSTEMD_RELAX_ESP_CHECKS=1 nixos-install \
      --root "$MNT_DIR" \
      --system "${toplevel}" \
      --no-root-passwd \
      --no-channel-copy

    echo "=> Optimizing the Nix store to save space..."
    sudo nix-store --store "$MNT_DIR" --optimise

    echo "=> Forcing Btrfs recursive compression on all files..."
    sudo btrfs filesystem defragment -r -v -czstd "$MNT_DIR"

    echo "=> Flushing write caches and unmounting cleanly..."
    cleanup
    trap - EXIT

    echo "=> Converting RootFS to Android sparse format..."
    img2simg "$OUT_DIR/rootfs.img" "$OUT_DIR/rootfs.sparse.img"

    echo "=> Generating SHA256 checksums for the output images..."
    sha256sum "$OUT_DIR/boot.img" > "$OUT_DIR/boot.img.sha256"
    sha256sum "$OUT_DIR/rootfs.sparse.img" > "$OUT_DIR/rootfs.sparse.img.sha256"

    echo "Done! 'boot.img' and 'rootfs.sparse.img' are ready for flashing."
  '';
}
