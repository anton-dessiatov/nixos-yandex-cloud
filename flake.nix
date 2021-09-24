{
  description = "NixOS image for Yandex Cloud";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
  };

  outputs = { self, nixpkgs }: {
    defaultPackage.x86_64-linux =
      with import nixpkgs { system = "x86_64-linux"; };
      stdenv.mkDerivation {
        name = "nixos-yandex-cloud";
        nativeBuildInputs = [ packer ];
      };
    devShell.x86_64-linux =
      with import nixpkgs { system = "x86_64-linux"; };
      mkShell {
        inputsFrom = [ self.defaultPackage.${system} ];
      };
  };
}
