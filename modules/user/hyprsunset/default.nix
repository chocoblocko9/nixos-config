{ lib, config, ... }:

{
  options = {
    userSettings.hyprsunset = {
      enable = lib.mkEnableOption "Enable hyprsunset";
    };
  };

  config = lib.mkIf config.userSettings.hyprsunset.enable {
    services.hyprsunset = {
      enable = false;
      settings = {
        max-gamma = 150;

        profile = [
          # Morning
          {
            time = "08:00";
            temperature = 4786;
            gamma = 0.87;
          }
          {
            time = "08:30";
            temperature = 5072;
            gamma = 0.89;
          }
          {
            time = "09:00";
            temperature = 5358;
            gamma = 0.91;
          }
          {
            time = "09:30";
            temperature = 5644;
            gamma = 0.93;
          }
          {
            time = "10:00";
            temperature = 5930;
            gamma = 0.95;
          }
          {
            time = "10:30";
            temperature = 6216;
            gamma = 0.97;
          }
          {
            time = "11:00";
            temperature = 6500;
            gamma = 1.0;
          }

          # Night
          {
            time = "21:00";
            temperature = 6300;
          }
          {
            time = "21:30";
            temperature = 6150;
          }
          {
            time = "22:00";
            temperature = 6000;
            gamma = 0.96;
          }
          {
            time = "22:30";
            temperature = 5850;
            gamma = 0.94;
          }
          {
            time = "23:00";
            temperature = 5700;
            gamma = 0.92;
          }
          {
            time = "23:30";
            temperature = 5550;
            gamma = 0.9;
          }
          {
            time = "00:00";
            temperature = 5400;
          }
          {
            time = "00:30";
            temperature = 5250;
            gamma = 0.88;
          }
          {
            time = "01:00";
            temperature = 5100;
          }
          {
            time = "01:30";
            temperature = 5000;
            gamma = 0.86;
          }
          {
            time = "02:00";
            temperature = 4800;
          }
          {
            time = "02:30";
            temperature = 4600;
            gamma = 0.85;
          }
          {
            time = "03:00";
            temperature = 4500;
          }
        ];
      };
    };
  };
}
