{ pkgs, ... }: {
  programs.neovim.enable = true;
  programs.neovim.viAlias = true;
  programs.neovim.vimAlias = true;
  programs.neovim.vimdiffAlias = true;

  # See https://github.com/nix-community/home-manager/issues/2040
  # for when this hack can be nuked
  programs.neovim.extraConfig = ''
    source ~/.config/nvim/config.vim
  '';

  # Stuff needed by plugins
  programs.neovim.withNodeJs = true;
  home.packages = with pkgs; [ zathura xdotool ];
}
