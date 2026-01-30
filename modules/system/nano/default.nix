{ lib, config, ... }:

{
  options = {
    systemSettings.nano = {
      enable = lib.mkEnableOption "Enable nano";
    };
  };

  config = lib.mkIf config.systemSettings.nano.enable {
    programs.nano = {
      enable = true;
      syntaxHighlight = true;
      nanorc = ''
        set softwrap
        set tabsize 2
        set zap
        set mouse
        set autoindent
      '';
    };
  };
}