{ config
, pkgs
, ... 
}:

{
  environment.systemPackages = with pkgs.vimPlugins ; [ 
    # Vim
    pkgs.vimHugeX  # see an editor famous for its advanced key stroke combinations - being good at vi is like being an olympic athlete
                   # * TODO: compare vimHugeX versus vim
    pkgs.neovim    # fork of vim with a more modern plugin architecture

    # Vim plugins
    vundle         # Vundle manages bundles (vim plugins)
                   # Support bundles
    vim-multiple-cursors
    tslime         # ?
    vimproc        # ?
    # supertab     # ?
    # syntastic    # ?
    # vim-bbye     # ?
    # vim-indent-guides # ?
    # gitignore    # ?
                   # Git
    fugitive       # ?
    extradite      # ?
                   # Bars, panels, and files
    vim-nerdtree-tabs # ? # Begriffs uses scrooloose/nerdtree'
    vim-airline     # better status line showing you which mode you're in, git info etc (light-weight version of powerline specializing in vim) 
    pkgs.powerline-fonts # fonts that improve the looks of airline
    ctrlp          # easily open files using ctrl+p
    tagbar         # ?
                   # Text manipulation
    easy-align     # alignment for comments, operators, etc
    Gundo          # ?
    commentary # ?
    tabular # ?
    surround       # manipulate / add surrounding brackets, quotes, etc
    gitgutter      # adds git icons (line added, removed, changed etc) to the gutter

    # vim-indent-object # ?
    # Allow pane movement to jump out of vim into tmux
    tmux-navigator # ?
    # Colorscheme
    wombat256      # grey color-scheme

    # Nix
    # vim-addon-nix # does not appear to work well

    # CoffeeScript
    coffee-script # syntax-highlighting for coffee-script

    # Haskell
    # haskell-vim # ?
    haskellConceal # ? # begriffs uses haskellConcealPlus
    ghcmod # ?
    neco-ghc # ?
    # vim-hoogle # ?
  ];
}