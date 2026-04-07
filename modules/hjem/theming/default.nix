{ pkgs, ... }:

{
  hjem.users.conor = {
    packages = with pkgs; [ # stable because theming takes SO long to build
      adw-gtk3
      numix-icon-theme
    ];
    files = {  
      ".config/gtk-3.0/gtk.css".source = ../../../themes/adw-solarized/gtk3-dark.css;
      ".config/gtk-4.0/gtk.css".source = ../../../themes/adw-solarized/gtk4-dark.css;
      ".config/Kvantum".source = ../../../themes/Kvantum;
    };
  };
}
