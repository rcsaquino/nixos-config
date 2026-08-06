# NixOS Config

Personal NixOS configuration managed with [flakes](https://nixos.wiki/wiki/Flakes).

## Layout

```
.
├── flake.nix            # Entry point: inputs and host definitions
├── modules/             # System modules (one file per concern)
├── dotfiles/            # Per-program dotfiles, symlinked into $HOME
├── scripts/             # Standalone utilities and tooling
└── assets/              # Wallpapers, icons, and misc assets
```

- **modules/** — Everything the system needs lives here. Add a file for a new
  concern; `flake.nix` only needs the import line.
- **dotfiles/** — One directory per program, managed with `scripts/dotf/dotf.sh`.
  Run it with no args to see available commands.
- **scripts/** — Utilities, some of which get installed into the system or
  referenced by modules.

## Usage

Rebuild with your hostname (a key under `nixosConfigurations` in `flake.nix`):

```sh
sudo nixos-rebuild switch --flake .#<host>
```

Other useful commands:

```sh
nix flake update                          # Update all inputs
sudo nixos-rebuild boot --flake .#<host>  # Rebuild for next boot
sudo nix-collect-garbage -d               # Clean old generations
```

## Dotfiles

```sh
scripts/dotf/dotf.sh list      # Show linked/unlinked programs
scripts/dotf/dotf.sh link fish # Symlink a program's dotfiles into $HOME
scripts/dotf/dotf.sh add mpv ~/.config/mpv  # Move a file in and link it
scripts/dotf/dotf.sh unlink fish
scripts/dotf/dotf.sh delete fish
```

## License

MIT — see [LICENSE](LICENSE).
