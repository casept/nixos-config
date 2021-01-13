{ pkgs, ... }: {
  programs.neovim.enable = true;
  programs.neovim.viAlias = true;
  programs.neovim.vimAlias = true;
  programs.neovim.vimdiffAlias = true;

  # Stuff needed by plugins
  programs.neovim.withNodeJs = true;
  home.packages = with pkgs; [ zathura xdotool ];
}
