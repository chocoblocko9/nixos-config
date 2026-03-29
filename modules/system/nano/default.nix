{
  programs.nano = {
    enable = true;
    syntaxHighlight = true;
    nanorc = ''
      set softwrap
      set tabsize 2
      set zap
      set mouse
      set autoindent
      set afterends
      set indicator
      set linenumbers
      set guidestripe 100
      set stripecolor bold,white,blue
    '';
  };
}
