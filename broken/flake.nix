{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";

    flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils-plus,
    agenix,
  }:
    flake-utils-plus.lib.mkFlake {
      inherit self inputs;

      channels.nixpkgs.overlaysBuilder = channels: [
        agenix.overlays.default
      ];

      outputsBuilder = channels: {
        packages.agenix = channels.nixpkgs.agenix;
      };
    };
}
