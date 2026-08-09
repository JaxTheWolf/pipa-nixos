# pipa-nixos: NixOS on Xiaomi Pad 6 (`pipa`)

Standalone NixOS hardware support and module flake for the **Xiaomi Pad 6** (Qualcomm Snapdragon 870 / `sm8250`, codename `pipa`).

---

## 🚀 Usage

### In your NixOS Flake

Add `pipa-nixos` to your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    pipa-nixos.url = "github:JaxTheWolf/pipa-nixos";
    pipa-nixos.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, pipa-nixos, ... }: {
    nixosConfigurations.pipa = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        pipa-nixos.nixosModules.default
        ./hosts/pipa
      ];
    };
  };
}
```

---

## 🛠️ Flake Outputs

- `nixosModules.default` (alias `nixosModules.pipa`, `nixosModules.xiaomi-pad-6`): Reusable NixOS hardware module.
- `overlays.default`: Nixpkgs overlay providing `pipa-kernel`, `pipa-firmware`, `pipa-headers`, and `qbootctl-pipa`.
- `packages.aarch64-linux`:
  - `pipa-kernel`: The custom sm8250 pipa kernel.
  - `pipa-firmware`: Xiaomi Pad 6 firmware package.
  - `pipa-headers`: Kernel headers.
  - `qbootctl-pipa`: Qualcomm A/B bootctl tool.
