{ lib, config, inputs, ... }:

{
  imports = [ inputs.nixcord.nixosModules.nixcord ];

  options = {
    systemSettings.nixcord = {
      enable = lib.mkEnableOption "Enable nixcord";
    };
  };

  config = lib.mkIf config.systemSettings.nixcord.enable {
    programs.nixcord = {
      enable = true;
      vesktop.enable = true;
      config = {
        themeLinks = [ https://raw.githubusercontent.com/chocoblocko9/Material-Discord-Cyan/refs/heads/master/Material-Discord.theme.css ];

        plugins = {
          fakeNitro.enable = true;
          fixSpotifyEmbeds = {
            enable = true;
            volume = 5.0;
          };
          fixYoutubeEmbeds.enable = true;
          implicitRelationships.enable = true;
          memberCount.enable = true;
          mentionAvatars.enable = true;
          moreQuickReactions = {
            enable = true;
            reactionCount = 6;
          };
          noUnblockToJump.enable = true;
          platformIndicators = {
            enable = true;
            consoleIcon = "vencord";
          };
          previewMessage.enable = true;
          replyTimestamp.enable = true;
          serverInfo.enable = true;
          translate.enable = true;
          shikiCodeblocks.enable = true;
          volumeBooster.enable = true;
          webScreenShareFixes.enable = true;
          whoReacted.enable = true;
          youtubeAdblock.enable = true;
        };
      };
    };
  };
}
