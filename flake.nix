{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOs/nixpkgs";
  };

  outputs = { self, nixpkgs,}:
    let
      # Systems supported
      allSystems = [
        "x86_64-linux" # 64-bit Intel/AMD Linux
        "aarch64-linux" # 64-bit ARM Linux
        "x86_64-darwin" # 64-bit Intel macOS
        "aarch64-darwin" # 64-bit ARM macOS
      ];

      # Helper to provide system-specific attributes
      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      # Development environment output
      devShells = forAllSystems ({ pkgs }: {
        default = pkgs.mkShell {
          # The Nix packages provided in the environment
          packages = with pkgs; [
            ocaml
            opam
            dune_3
            ocamlPackages.utop
            ocamlPackages.core
            ocamlPackages.base
            ocamlPackages.mirage
            ocamlPackages.ocaml-lsp
            ocamlPackages.ounit2
          ];
        };
      });
    };
}
