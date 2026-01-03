{
  config,
  pkgs,
  lib,
  targetDir,
  ...
}:
{
  home = {
    enableNixpkgsReleaseCheck = false;
    sessionPath = [
      "${config.xdg.configHome}/bin"
    ];
    stateVersion = "25.11";
  };
  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      silent = true;
    };
    fish = {
      enable = true;
      binds = {
        "shift-tab" = {
          mode = "insert";
          command = "accept-autosuggestion";
        };
      };
      functions = {
        fish_greeting = "";
        fish_mode_prompt = "";
        fish_prompt = ''
          echo -n (string repeat -n "$(tput cols)" "─")\n(set_color cyan -o)(prompt_pwd)\n(set_color normal)(set_color black -b white)" $(whoami) "(set_color normal)(set_color white)" "(set_color normal)
        '';
      };
      interactiveShellInit = ''
        # General
        set -g fish_key_bindings fish_vi_key_bindings
        set -g fish_cursor_default block
        set -g fish_cursor_insert block

        # fzf
        set -x FZF_DEFAULT_COMMAND "fd --type file"
        set -x FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS \
        --color=fg+:#c0caf5,bg+:#1a1b26,hl+:#c0caf5 \
        --color=fg:#c0caf5,bg:#1a1b26,hl:#c0caf5 \
        --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff \
        --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a \
        --info=inline-right \
        --marker='—' \
        --pointer='—' \
        --prompt='— ' \
        "
      '';
    };
    ghostty = {
      enable = true;
      settings = {
        # General
        auto-update = "check";
        auto-update-channel = "tip";
        clipboard-paste-protection = false;
        clipboard-trim-trailing-spaces = true;
        command = "${pkgs.fish}/bin/fish --interactive --login";
        confirm-close-surface = false;
        copy-on-select = "clipboard";
        cursor-style = "block";
        cursor-style-blink = "false";
        font-family = "IBM Plex Mono";
        font-feature = "-calt";
        font-size = 14;
        font-thicken = true;
        macos-titlebar-style = "tabs";
        macos-window-shadow = false;
        maximize = true;
        quick-terminal-animation-duration = 0;
        shell-integration-features = "no-cursor";
        window-colorspace = "display-p3";
        window-inherit-working-directory = false;
        window-padding-balance = true;
        window-padding-x = 8;
        window-padding-y = 3;
        window-save-state = "never";

        # Colors
        background = "#1a1b26";
        cursor-color = "#c0caf5";
        foreground = "#c0caf5";
        palette = [
          "0=#15161e"
          "10=#9fe044"
          "11=#faba4a"
          "12=#8db0ff"
          "13=#c7a9ff"
          "14=#a4daff"
          "15=#c0caf5"
          "1=#f7768e"
          "2=#9ece6a"
          "3=#e0af68"
          "4=#7aa2f7"
          "5=#bb9af7"
          "6=#7dcfff"
          "7=#a9b1d6"
          "8=#414868"
          "9=#ff899d"
        ];
        selection-background = "#283457";
        selection-foreground = "#c0caf5";

        # Keybinds
        keybind = [
          "global:cmd+backquote=toggle_quick_terminal"
          "global:shift+alt+e=new_window"
          "shift+enter=text:\\x1b\\r"
        ];
      };
    };
    git = {
      enable = true;
      settings = {
        core = {
          autocrlf = "input";
          editor = "nvim";
        };
        init.defaultBranch = "main";
        pull.rebase = true;
        user = {
          email = "me@denniseum.com";
          name = "dseum";
        };
      };
    };
    neovim = {
      enable = true;
      defaultEditor = true;
    };
    tmux = {
      enable = true;
      baseIndex = 1;
      clock24 = true;
      escapeTime = 10;
      extraConfig = ''
        # General
        set -as terminal-overrides ',*:Setulc=\E[58::2::::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'
        set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'
        set -g bell-action none
        set -g status-left-length 40
        set -g visual-activity off
        set -g visual-bell off
        set -g visual-silence off
        set -gq allow-passthrough on
        setw -g monitor-activity off
        setw -g pane-border-status off

        # Indexing
        set -g base-index 1
        set -g renumber-windows on

        # Theme
        set -g message-command-style "fg=#7aa2f7,bg=#3b4261"
        set -g message-style "fg=#7aa2f7,bg=#3b4261"
        set -g mode-style "fg=#7aa2f7,bg=#3b4261"
        set -g pane-active-border-style "fg=#787e9c"
        set -g pane-border-style "fg=#787e9c"
        set -g status "on"
        set -g status-justify "left"
        set -g status-left ""
        set -g status-left-length "100"
        set -g status-left-style NONE
        set -g status-right "#[fg=#15161e,bg=#7aa2f7,bold] #S "
        set -g status-right-length "100"
        set -g status-right-style NONE
        set -g status-style "fg=#7aa2f7,bg=#16161e"
        setw -g window-status-activity-style "underscore,fg=#a9b1d6,bg=#16161e"
        setw -g window-status-current-format "#[fg=#7aa2f7,bg=#3b4261,bold] #I – #W #[fg=#3b4261,bg=#16161e,nobold,nounderscore,noitalics] "
        setw -g window-status-format "#[default] #I – #W #[fg=#16161e,bg=#16161e,nobold,nounderscore,noitalics] "
        setw -g window-status-separator ""
        setw -g window-status-style "NONE,fg=#a9b1d6,bg=#16161e"

        # Keymaps
        bind % split-window -h -c "#{pane_current_path}"
        bind '"' split-window -v -c "#{pane_current_path}"
        bind X confirm-before kill-session
        bind c new-window -c "#{pane_current_path}"
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R
        bind s choose-tree -ZsK '#{?#{e|<:#{line},9},#{e|+:1,#{line}},#{?#{e|<:#{line},35},M-#{a:#{e|+:97,#{e|-:#{line},9}}},}}'
        bind w choose-tree -ZK '#{?#{e|<:#{line},9},#{e|+:1,#{line}},#{?#{e|<:#{line},35},M-#{a:#{e|+:97,#{e|-:#{line},9}}},}}'
      '';
      focusEvents = true;
      historyLimit = 50000;
      keyMode = "vi";
      mouse = true;
      shell = "${pkgs.fish}/bin/fish";
      terminal = "$TERM";
    };
    vscode = {
      enable = true;
      mutableExtensionsDir = false;
      profiles.default = {
        enableExtensionUpdateCheck = false;
        enableUpdateCheck = false;
        extensions = with pkgs.nix-vscode-extensions.vscode-marketplace; [
          bradlc.vscode-tailwindcss
          charliermarsh.ruff
          dart-code.dart-code
          dbaeumer.vscode-eslint
          docker.docker
          enkia.tokyo-night
          esbenp.prettier-vscode
          james-yu.latex-workshop
          keenethics.keen-neutral-icon-theme
          mermaidchart.vscode-mermaid-chart
          mjmlio.vscode-mjml
          ms-azuretools.vscode-containers
          ms-azuretools.vscode-docker
          ms-python.python
          ms-toolsai.jupyter
          ms-toolsai.jupyter-keymap
          ms-toolsai.jupyter-renderers
          ms-toolsai.vscode-jupyter-cell-tags
          ms-toolsai.vscode-jupyter-slideshow
          ms-vscode-remote.remote-containers
          ms-vscode-remote.remote-wsl-recommender
          ms-vscode.makefile-tools
          ms-vsliveshare.vsliveshare
          ocamllabs.ocaml-platform
          rebornix.toggle
          reditorsupport.r
          reditorsupport.r-syntax
          rust-lang.rust-analyzer
          svelte.svelte-vscode
          vscodevim.vim
        ];
        keybindings = builtins.fromJSON (builtins.readFile ./config/vscode/keybindings.json);
        userSettings = builtins.fromJSON (builtins.readFile ./config/vscode/settings.json);
      };
    };
    zsh = {
      enable = true;
      dotDir = config.xdg.configHome + "/zsh";
      enableCompletion = true;
      initContent = ''
        # Options
        setopt NO_CASE_GLOB
        setopt PROMPT_SUBST
        setopt CORRECT
        bindkey -v

        # Prompt
        PROMPT=$'%F{#787e9c}''${(r:$COLUMNS::\u2500:)}%f\n%F{cyan}%B%2~%b%f\n%K{white}%F{black} %n %f%k%F{white}%f '

        # fzf
        export FZF_DEFAULT_COMMAND="fd --type file"
        export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
        --color=fg+:#c0caf5,bg+:#1a1b26,hl+:#c0caf5 \
        --color=fg:#c0caf5,bg:#1a1b26,hl:#c0caf5 \
        --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff \
        --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a \
        --info=inline-right \
        --marker='—' \
        --pointer='—' \
        --prompt='— ' \
        "
      '';
    };
  };
  xdg.configFile."bin" = {
    source = config.lib.file.mkOutOfStoreSymlink (targetDir + "/module/shared/config/bin");
    recursive = true;
  };
  xdg.configFile."nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink (targetDir + "/module/shared/config/nvim");
    recursive = true;
  };
  xdg.configFile."vim" = {
    source = config.lib.file.mkOutOfStoreSymlink (targetDir + "/module/shared/config/vim");
    recursive = true;
  };
}
