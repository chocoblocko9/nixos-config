{ lib, config, ... }:

{
  options = {
    systemSettings.firefox = {
      enable = lib.mkEnableOption "Enable firefox with my extensions";
    };
  };

  config = lib.mkIf config.systemSettings.firefox.enable {
    programs.firefox = {
      enable = true;
      policies = {
        "policies": {
          "ExtensionSettings": {          
            "*": {
              "installation_mode": "allowed"
            },
            "uBlock0@raymondhill.net": {
              "installation_mode": "force_installed",
              "install_url": "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi"
              "private_browsing": true
            },
            "{d47b636a-26d2-4b46-a276-e1cbd17fb5e5}": {
              "installation_mode": "force_installed",
              "install_url": "https://addons.mozilla.org/firefox/downloads/latest/6bafabdbc9de47aca1c7/latest.xpi"
              "private_browsing": true
            },
            "{f4f4223a-ff30-4961-b9c0-6a71b7a32aaf}": {
              "installation_mode": "force_installed",
              "install_url": "https://addons.mozilla.org/firefox/downloads/latest/roseal/latest.xpi"
              "private_browsing": true
            },
            "addon@darkreader.org": {
              "installation_mode": "force_installed",
              "install_url": "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi"
              "private_browsing": true
            },
            "{8927f234-4dd9-48b1-bf76-44a9e153eee0}": {
              "installation_mode": "force_installed",
              "install_url": "https://addons.mozilla.org/firefox/downloads/latest/better-canvas/latest.xpi"
              "private_browsing": true
            },
            "{12cf650b-1822-40aa-bff0-996df6948878}": {
              "installation_mode": "force_installed",
              "install_url": "https://addons.mozilla.org/firefox/downloads/latest/cookies-txt/latest.xpi"
              "private_browsing": true
            },
            "queryamoid@kaply.com": {
              "installation_mode": "force_installed",
              "install_url": "https://github.com/mkaply/queryamoid/releases/download/v0.1/query_amo_addon_id-0.1-fx.xpi"
              "private_browsing": true
            },
            "Tab-Session-Manager@sienori": {
              "installation_mode": "force_installed",
              "install_url": "https://addons.mozilla.org/firefox/downloads/latest/tab-session-manager/latest.xpi"
              "private_browsing": true
            },
            "firefox@tampermonkey.net": {
              "installation_mode": "force_installed",
              "install_url": "https://addons.mozilla.org/firefox/downloads/latest/tab-session-manager/latest.xpi"
              "private_browsing": true
            },
            "{e8ffc3db-2875-4c7f-af38-d03e7f7f8ab9}": {
              "installation_mode": "force_installed",
              "install_url": "https://addons.mozilla.org/firefox/downloads/latest/docsafterdark/latest.xpi"
              "private_browsing": true
            },
            "@hideyoutubecontrolls": {
              "installation_mode": "force_installed",
              "install_url": "https://addons.mozilla.org/firefox/downloads/latest/hide-youtube-controls/latest.xpi"
              "private_browsing": true
            }
          }
        }
      }
    }
  };
}