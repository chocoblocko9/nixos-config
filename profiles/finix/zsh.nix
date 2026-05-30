{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.zsh;
in
{
  options.programs.zsh = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable [zsh](${pkgs.zsh.meta.homepage}).
      '';
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.zsh;
      defaultText = lib.literalExpression "pkgs.zsh";
      description = ''
        The package to use for `zsh`.
      '';
    };


    enableCompletion = lib.mkOption {
      default = true;
      description = ''
        Enable zsh completion for all interactive zsh shells.
      '';
      type = lib.types.bool;
    };

    enableBashCompletion = lib.mkOption {
      default = false;
      description = ''
        Enable compatibility with bash's programmable completion system.
      '';
      type = lib.types.bool;
    };

    enableLsColors = lib.mkOption {
      default = true;
      description = ''
        Enable extra colors in directory listings (used by `ls` and `tree`).
      '';
      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {

    environment.etc.zshenv.text = ''
      # /etc/zshenv: DO NOT EDIT -- this file has been generated automatically.
      # This file is read for all shells.

      # Only execute this file once per shell.
      if [ -n "''${__ETC_ZSHENV_SOURCED-}" ]; then return; fi
      __ETC_ZSHENV_SOURCED=1

      HELPDIR="${pkgs.zsh}/share/zsh/$ZSH_VERSION/help"

      source ~/set-environment

      # Tell zsh how to find installed completions.
      for p in ''${(z)NIX_PROFILES}; do
          fpath=($p/share/zsh/site-functions $p/share/zsh/$ZSH_VERSION/functions $p/share/zsh/vendor-completions $fpath)
      done

      # Read system-wide modifications.
      if test -f /etc/zshenv.local; then
          . /etc/zshenv.local
      fi
    '';

    environment.etc.zshrc.text = ''
      # /etc/zshrc: DO NOT EDIT -- this file has been generated automatically.
      # This file is read for interactive shells.
      #

      # Only execute this file once per shell.
      if [ -n "$__ETC_ZSHRC_SOURCED" -o -n "$NOSYSZSHRC" ]; then return; fi
      __ETC_ZSHRC_SOURCED=1

      HOST=${config.networking.hostName}

      # Force emacs keybindings for all interactive shells
      bindkey -e

      # Configure sane keyboard defaults.
      . /etc/zinputrc

      SAVEHIST=9999
      HISTSIZE=9999
      HISTFILE=$HOME/.zsh_history

      autoload -U promptinit && promptinit && prompt suse && setopt prompt_sp
      autoload -Uz colors && colors
      autoload -U compinit && compinit

      ${lib.optionalString cfg.enableBashCompletion ''
        # Enable compatibility with bash's completion system.
        autoload -U bashcompinit && bashcompinit
      ''}

      ${lib.optionalString cfg.enableLsColors ''
        # Extra colors for directory listings.
        eval "$(${pkgs.coreutils}/bin/dircolors -b)"
      ''}

      source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

      if ${lib.boolToString config.programs.direnv.loadInNixShell} || printenv PATH | grep -vqc '/nix/store'; then
          eval "$(${lib.getExe config.programs.direnv.package} hook zsh)"
      fi

      ZSH_HIGHLIGHT_HIGHLIGHTERS=( main )

      # Disable some features to support TRAMP.
      if [ "$TERM" = dumb ]; then
          unsetopt zle prompt_cr prompt_subst
          unset RPS1 RPROMPT
          PS1='$ '
          PROMPT='$ '
      fi

      # Read system-wide modifications.
      if test -f /etc/zshrc.local; then
          . /etc/zshrc.local
      fi

      eval "$(direnv hook zsh)"
    '';

    environment.etc.zinputrc.source = ./zinputrc;

    environment.systemPackages = [
      pkgs.zsh
      pkgs.zsh-syntax-highlighting
    ]
    ++ lib.optional cfg.enableCompletion pkgs.nix-zsh-completions;

    environment.pathsToLink = [ "/share/zsh" ];

    environment.shells = [
      "/run/current-system/sw/bin/zsh"
      "${pkgs.zsh}/bin/zsh"
    ];
  };
}
