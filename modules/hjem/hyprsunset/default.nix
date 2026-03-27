{ lib, config, pkgs, ... }:

{
  options = {
    hjemSettings.hyprsunset = {
      enable = lib.mkEnableOption "Enable hyprsunset";
    };
  };

  config = lib.mkIf config.hjemSettings.hyprsunset.enable {
    hjem.users.${config.userName} = {
      packages = [ pkgs.hyprsunset ];

      files.".config/hypr/hyprsunset.conf".text = ''
        max-gamma = 150

        # Morning
        profile {
          time = 08:00
          temperature = 4786
          gamma = 0.87
        }
        profile {
          time = 08:30
          temperature = 5072
          gamma = 0.89;
        }
        profile {
          time = 09:00
          temperature = 5358
          gamma = 0.91
        }
        profile {
          time = 09:30
          temperature = 5644
          gamma = 0.93
        }
        profile {
          time = 10:00
          temperature = 5930
          gamma = 0.95
        }
        profile {
          time = 10:30
          temperature = 6216
          gamma = 0.97
        }
        profile {
          time = 11:00
          temperature = 6500
          gamma = 1.0
        }

        # Night
        profile {
          time = 21:00
          temperature = 6300
        }
        
        profile {
          time = 21:30
          temperature = 6150
        }
        
        profile {
          time = 22:00
          temperature = 6000
          gamma = 0.96
        }

        profile {
          time = 22:30
          temperature = 5850
          gamma = 0.94
        }
        
        profile {
          time = 23:00
          temperature = 5700
          gamma = 0.92
        }
        
        profile {
          time = 23:30
          temperature = 5550
          gamma = 0.9
        }
        
        profile {
          time = 00:00
          temperature = 5400
        }
        
        profile {
          time = 00:30
          temperature = 5250
          gamma = 0.88
        }

        profile {
          time = 01:00
          temperature = 5100
        }
        
        profile {
          time = 01:30
          temperature = 5000
          gamma = 0.86
        }

        profile {
          time = 02:00
          temperature = 4800
        }
        
        profile {
          time = 02:30
          temperature = 4600
          gamma = 0.85
        }

        profile {
          time = 03:00
          temperature = 4500
        } 
      '';
    };
  };
}
