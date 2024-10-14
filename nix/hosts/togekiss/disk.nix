{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              label = "boot";
              size = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            encryptedSwap = {
              size = "4G";
              content = {
                type = "swap";
                randomEncryption = true;
                priority = 100;
              };
            };
            swap = {
              size = "16G";
              content = {
                type = "swap";
                discardPolicy = "both"; 
                resumeDevice = true;
              };
            };
            luks = {
              size = "100%";
              label = "luks";
              content = {
                type = "luks";
                name = "nixos";
                settings = {
                  allowDiscards = true;
                  crypttabExtraOpts = [ "fido2-device=auto" "token-timeout=10"];
                };
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                };
              };
            };
          };
        };
      };
    };
  };
}
