{ config
, ...
}:

let
  myhydraserver = # http://mydomain.com:3000; #gitignore
in
{
  nix = {
    # package = pkgs.nixUnstable; # ?

    buildCores = 6;     # allow many parallel tasks when building packages

    # perform nix garbage collection (delete unused programs) automatically for stuff older than 30 days 
    gc = {
      automatic = false;
      dates = "03:15"; # most people are asleep at 03:15 in the morning, so this might be a good time to run it
      options = "--delete-older-than 30d";
    };

    # this might be useful to you if you develop nix packages
    # * useChroot sandboxes your builds so that they are completely pure, but adds some overhead
    # * extraOptions are appended to your nix.conf (see https://nixos.org/wiki/FAQ#How_to_keep_build-time_dependencies_around_.2F_be_able_to_rebuild_while_being_offline.3F)
    # * build-cores = 0 means that the builder should use all available CPU cores in the system 
    # useChroot = true; # using the default false because this could be slow
    extraOptions = ''
      gc-keep-outputs = true
      gc-keep-derivations = true
    ''; 

    # export NIX_PATH=$NIX_PATH:unstablepkgs=/nix/var/nix/profiles/per-user/root/channels/nixos-unstable/nixpkgs:devpkgs=${config.users.users.me.home}/projects/config/nixpkgs
    nixPath = [
      # Default nix paths
      "/nix/var/nix/profiles/per-user/root/channels/nixos"
      "nixos-config=/etc/nixos/configuration.nix"
      "/nix/var/nix/profiles/per-user/root/channels"
      # Added
      "unstablepkgs=/nix/var/nix/profiles/per-user/root/channels/nixos-unstable/nixpkgs"
      "devpkgs=${config.users.users.me.home}/projects/config/nixpkgs"
    ];

    binaryCaches = 
        [
          myhydraserver
          http://cache.nixos.org/
        ];
    binaryCachePublicKeys =
    [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
    requireSignedBinaryCaches = false; # Needed for personal hydra cache
    trustedBinaryCaches = 
    [
      myhydraserver
      https://hydra.circuithub.com
    ];
  };
}

