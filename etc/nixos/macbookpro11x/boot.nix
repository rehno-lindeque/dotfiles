{
  pkgs
, lib
, config
, ... 
}:

let
   # # All patches, services, etc from https://aur.archlinux.org/pkgbase/linux-macbook/?comments=all
   # # nix-prefetch remote https://aur.archlinux.org/linux-macbook.git
   # linux-macbook = pkgs.fetchgit {
   #    url = "https://aur.archlinux.org/linux-macbook.git";
   #    /* sha256 = "091kvsrsrzwsy1905n85g1bzzf23dcy3rgcvq3ng6nzxhg7a9yq5"; */
   #    /* rev = "1c00d30fae794c263c9a5f274e5a704ab329343c"; */
   #    "rev" = "b216fa21a2b21696b68fd37964a2a57bf6171125";
   #    "sha256" = "17g8kfgp9ifd876jraa4cy5279p55953wv7hcs2581w6w75xrxfr";
   #  };

   # https://wiki.archlinux.org/index.php/MacBookPro11,x#Screen_backlight
   macbook-apple-gmux =
      { name = "macbook-apple-gmux";
        /* patch = ./apple-gmux.patch; */
        patch = "${pkgs.arch-linux-macbook.outPath}/01-apple-gmux.patch";
      };
   macbook-intel-pstate-backport =
      { name = "macbook-intel-pstate-backport";
        patch = "intel-pstate-backport.patch";
      };

   # https://wiki.archlinux.org/index.php/Mac#Suspend_.26_Power_Off_.2811.2C4.2B.29
   # https://bugzilla.kernel.org/show_bug.cgi?id=103211
   macbook-suspend =
      { name = "macbook-suspend";
        patch = "${pkgs.arch-linux-macbook.outPath}/02-macbook-suspend.patch";
      };
    macbook-apple-poweroff-quirk-workaround =
      { name = "apple-poweroff-quirk-workaround.patch";
        patch = "${pkgs.arch-linux-macbook.outPath}/03-apple-poweroff-quirk-workaround.patch";
        # See https://aur.archlinux.org/pkgbase/linux-macbook/?comments=all#comment-602949
        # patch = pkgs.fetchurl {
        #   url = "https://patchwork.kernel.org/patch/9821775/raw/";
        #   sha256 =  "0nh279ddwc0xipncrwvf6mgjlc3zfz8321ilbgn440nsk5gv9g23";
        # };
      };
    change-default-console-loglevel =
      { name = "change-default-console-loglevel";
        patch = "${pkgs.arch-linux-macbook.outPath}/change-default-console-loglevel.patch";
      };

    linux_default =
      {
        kernelPackages = pkgs.linuxPackages;
        # kernelPatches =
        #   [
        #     # Makes backlight and suspend work
        #     # macbook-apple-gmux

        #     # macbook-intel-pstate-backport
        #     # macbook-suspend
        #     # macbook-apple-poweroff-quirk-workaround

        #     # # Needed?
        #     # change-default-console-loglevel
        #   ];
      };
    linux_4_14 =
      {
        kernelPackages = pkgs.linuxPackages_4_14;
        kernelPatches = linux_default.kernelPatches ++ [];
        blacklistedKernelModules = [];
      };
    # linux_4_17 =
    #   {
    #     kernelPackages = pkgs.linuxPackages_4_17;
    #   };
    linux_4_20 =
      {
        kernelPackages = pkgs.linuxPackages_4_20;
      };
    linux_5_1 =
      {
        kernelPackages = pkgs.linuxPackages_5_1_rc4;
      };
    linux_latest =
      {
        kernelPackages = pkgs.linuxPackages_latest;
        kernelPatches = linux_default.kernelPatches ++ [];
        blacklistedKernelModules = [];
      };
in
{

  # TODO: possible battery powersaving features
  /* boot = { */
  /*   kernelParams = [ "pcie_aspm.policy=powersave" ]; */
  /*   blacklistedKernelModules = [ "uvcvideo" ]; */
  /*   extraModprobeConfig = '' */
  /*     options snd_hda_intel power_save=1 */
  /*     options iwlwifi power_save=1 d0i3_disable=0 uapsd_disable=0 */
  /*     options iwldvm force_cam=0 */
  /*   ''; */
  /*   kernel.sysctl = { */
  /*     "kernel.nmi_watchdog" = 0; */
  /*     "vm.dirty_writeback_centisecs" = 6000; */
  /*     "vm.laptop_mode" = 5; */
  /*   }; */
  /* }; */




  boot =
    rec {
      # TODO: see https://github.com/fooblahblah/nixos/blob/63457072af7b558f63cc5ccec5a75b90a14f35f7/hardware-configuration-mbp.nix
      initrd =
        {
          availableKernelModules = [
              "xhci_pci"
              "ahci"
              "usbhid"
              "usb_storage"
              "sd_mod"
            ];

          luks.devices =
            [
              {
                name = "nixosroot"; # "luksroot";
                device = "/dev/disk/by-uuid/95a903c1-2a2f-44b9-90c2-cd810ea18cd4";
              }
            ];
        };

      inherit (linux_default) kernelPackages;
      # inherit (linux_4_14) kernelPackages kernelPatches blacklistedKernelModules;
      # inherit (linux_4_17) kernelPackages;
      # inherit (linux_latest) kernelPackages kernelPatches blacklistedKernelModules;
      # inherit (linux_4_20) kernelPackages;
      # inherit (linux_5_1) kernelPackages;

      kernelParams =
        let
          # kernelVersion = config.boot.kernelPackages.kernel.version;
          kernelVersion = kernelPackages.kernel.version;
        in
          # Adding 'acpi_osi=' to kernel parameters reportedly brings the battery life of a MacBook Air 2013 from 5 hours to 11-12 hours. See this forum post for more information.
          # * https://wiki.archlinux.org/index.php/Mac#Power_management
          # * https://wiki.archlinux.org/index.php/MacBookPro11,x#Kernel_parameters
          # * https://bugzilla.kernel.org/show_bug.cgi?id=177151#c10
          # * https://bugs.freedesktop.org/show_bug.cgi?id=96645 (TODO: patch)
          ( if lib.versionOlder kernelVersion "4.17"
            then [ "acpi_osi=" ] # TODO: May not be necessary anymore
            else [ "acpi_osi=Darwin" ] # TODO: May not be necessary?
          )
          # [ "acpi_osi=Darwin" ]
          ++ (if lib.versionOlder kernelVersion "4.10" then [] else [ "intremap=nosid" ]);

      loader.grub.enable = false;

      # Apparently needed to make sound output and mic work
      # TODO: is model=115 correct? I've see model=101 but this isn't in any documentation on the internet
      #       we may want to make this model=auto or leave it out entirely
      extraModprobeConfig =
        # options libata.force=noncq
        ''
        options snd_hda_intel index=0 model=intel-mac-auto id=PCH
        options snd_hda_intel index=1 model=intel-mac-auto id=HDMI
        options snd_hda_intel model=115
        '' +
        # https://loicpefferkorn.net/2015/01/arch-linux-on-macbook-pro-retina-2014-with-dm-crypt-lvm-and-suspend-to-disk/#intel-audio-chipset
        ''
        options snd_hda_intel power_save=1
        '' +
        # Make the function keys (F1-F12) the default, and put media keys behind the fn key
        # * https://wiki.archlinux.org/index.php/Apple_Keyboard#Function_keys_do_not_work
        ''
        options hid_apple fnmode=2
        '' +
        # Documentation for tlp configuration RADEON_DPM_STATE_ON_AC and RADEON_DPM_STATE_ON_BAT says this is necessary
        # $ systool -v -m radeon | grep dpm 
        # shows that it is off by default while https://wiki.archlinux.org/index.php/ATI#Powersaving implies that it is supported for R6xx and newer chips
        ''
        ''
        # options radeon.dpm=1
        # # Turning on explicitly (probably default)
        # # active state power management seems like a good idea
        # # * See http://www.phoronix.com/scan.php?page=news_item&px=MTQxMzM
        # ''
        # options radeon.aspm=1
        # '' +
        # # Turning on explicitly (probably default)
        # # * https://kernelnewbies.org/Linux_3.13#head-f95c198f6fdc7defe36f470dc8369cf0e16898df
        # # * See http://blog.laplante.io/2014/07/disable-radeon-power-management-newer-linux-kernels/
        # ''
        # options radeon.runpm=1
        # '' +
        # # allows graphical boot and instant console switching etc
        # # * See https://wiki.archlinux.org/index.php/kernel_mode_setting
        # ''
        # options radeon.modeset=1
        # ''
        # This option is a nice idea, but seems to freeze startup after forcible shutdown
        # ''
        # options resume=/dev/sda4
        # ''
        ;
    };
}

