{ config, pkgs, lib, ... }:

{
  imports =
    [ 
      # Include the results of the hardware scan.
      <nixpkgs/nixos/modules/hardware/network/broadcom-43xx.nix>
      <nixpkgs/nixos/modules/installer/scan/not-detected.nix>

      # ...
      # ../macbookpro/configuration.nix
      ../macbookpro/services.nix
      # ../macbook/boot.nix
      ../macbook/networking.nix
      ../macbook/powerManagement.nix
      ../macbook/hardware.nix
      ../macbook/services.nix

      # Configuration for the retina screen
      ../retina/configuration.nix

       # ...
      ./boot.nix
      ./fileSystems.nix
      ./nix.nix
      ./nixpkgs.nix
      ./services.nix
      ./hardware.nix
      ./users.nix
    ];
}
