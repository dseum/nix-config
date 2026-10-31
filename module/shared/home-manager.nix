{
  config,
  pkgs,
  targetDir,
  ...
}:
{
  home.stateVersion = "26.05";
  programs = {
    claude-code = {
      enable = true;
      enableMcpIntegration = true;
      context = ./config/agents/AGENTS.md;
      skills = {
        asd = ./config/agents/skills/asd;
        review-abstractions = ./config/agents/skills/review-abstractions;
        review-comments = ./config/agents/skills/review-comments;
        review-workflows = ./config/agents/skills/review-workflows;
        squash = ./config/agents/skills/squash;
      };
      settings = {
        tui = "fullscreen";
        extraKnownMarketplaces.svelte.source = {
          source = "github";
          repo = "sveltejs/ai-tools";
        };
        enabledPlugins = {
          "svelte@svelte" = true;
          "frontend-design@claude-plugins-official" = true;
        };
      };
    };
    codex = {
      enable = true;
      enableMcpIntegration = true;
      context = ./config/agents/AGENTS.md;
      mutableSettings = true;
      settings = {
        approval_policy = "never";
        check_for_update_on_startup = false;
        cli_auth_credentials_store = "keyring";
        feedback.enabled = false;
        features = {
          memories = true;
          prevent_idle_sleep = true;
        };
        file_opener = "none";
        model = "gpt-6.1-sol";
        model_reasoning_effort = "high";
        model_reasoning_summary = "concise";
        model_verbosity = "low";
        personality = "none";
        plan_mode_reasoning_effort = "max";
        sandbox_mode = "danger-full-access";
        service_tier = "fast";
        tui = {
          notification_method = "osc9";
          notifications = [ "agent-turn-complete" ];
        };
        web_search = "live";
      };
      skills = {
        asd = ./config/agents/skills/asd;
        review-abstractions = ./config/agents/skills/review-abstractions;
        review-comments = ./config/agents/skills/review-comments;
        review-workflows = ./config/agents/skills/review-workflows;
        squash = ./config/agents/skills/squash;
      };
    };
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
          echo -n (set_color cyan -o)(prompt_pwd)\n(set_color normal)(set_color black -b white)" $USER "(set_color normal)(set_color white)" "(set_color normal)
        '';
      };
      interactiveShellInit = ''
        # General
        set -g fish_key_bindings fish_vi_key_bindings
        set -g fish_cursor_default block
        set -g fish_cursor_insert block
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
        cursor-style-blink = false;
        font-family = "IBM Plex Mono";
        font-feature = "-calt";
        font-size = 13;
        font-thicken = true;
        macos-titlebar-style = "tabs";
        macos-window-shadow = false;
        maximize = true;
        quick-terminal-animation-duration = 0;
        shell-integration-features = "ssh-terminfo,ssh-env,no-cursor";
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
        push.autoSetupRemote = true;
        user = {
          email = "me@denniseum.com";
          name = "dseum";
        };
      };
    };
    mcp = {
      enable = true;
      servers.superlogical.url = "https://www.superlogical.com/rex/community-mcp";
    };
    neovim = {
      enable = true;
      defaultEditor = true;
      sideloadInitLua = true;
      extraPackages = [
        pkgs.bash-language-server
        pkgs.caddy
        pkgs.clang-tools
        pkgs.cmake-format
        pkgs.dart
        pkgs.docker-compose-language-service
        pkgs.dockerfile-language-server
        pkgs.fish
        pkgs.gopls
        pkgs.go
        pkgs.hclfmt
        pkgs.just
        pkgs.lua-language-server
        pkgs.nixd
        pkgs.nixfmt
        pkgs.ocamlPackages.ocaml-lsp
        pkgs.ocamlPackages.ocamlformat
        pkgs.prettierd
        pkgs.ruff
        pkgs.rust-analyzer
        pkgs.rustfmt
        pkgs.shfmt
        pkgs.stylua
        pkgs.svelte-language-server
        pkgs.tailwindcss-language-server
        pkgs.taplo
        pkgs.tex-fmt
        pkgs.texlab
        pkgs.ty
        pkgs.typescript-language-server
        pkgs.vscode-langservers-extracted
        pkgs.yaml-language-server
        pkgs.zls
      ];
    };
    nix-index.enable = false;
    nix-index-database.comma.enable = true;
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
        set -g visual-activity off
        set -g visual-bell off
        set -g visual-silence off
        set -gq allow-passthrough on
        setw -g monitor-activity off
        setw -g pane-border-status off

        # Indexing
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
        bind c new-window -a -c "#{pane_current_path}"
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
      terminal = "tmux-256color";
    };
    zsh = {
      enable = true;
      dotDir = config.xdg.configHome + "/zsh";
      defaultKeymap = "viins";
      autosuggestion = {
        enable = true;
        highlight = "fg=8";
        strategy = [
          "history"
          "completion"
        ];
      };
      syntaxHighlighting = {
        enable = true;
        styles = {
          default = "fg=cyan";
          arg0 = "none";
          reserved-word = "none";
          suffix-alias = "none";
          global-alias = "fg=cyan";
          precommand = "none";
          autodirectory = "underline";
          path = "fg=cyan,underline";
          path_prefix = "fg=cyan,underline";
          unknown-token = "fg=9";
          commandseparator = "fg=green";
          redirection = "fg=cyan,bold";
          single-hyphen-option = "fg=cyan";
          double-hyphen-option = "fg=cyan";
          single-quoted-argument = "fg=yellow";
          double-quoted-argument = "fg=yellow";
          dollar-quoted-argument = "fg=yellow";
          dollar-double-quoted-argument = "fg=14";
          back-double-quoted-argument = "fg=14";
          back-dollar-quoted-argument = "fg=14";
          rc-quote = "fg=14";
          globbing = "fg=14";
          history-expansion = "fg=14";
          command-substitution-delimiter = "fg=14";
          process-substitution-delimiter = "fg=14";
          back-quoted-argument-delimiter = "fg=14";
          assign = "fg=cyan";
          comment = "fg=red";
        };
      };
      initContent = ''
        setopt AUTO_CD INTERACTIVE_COMMENTS
        unsetopt BANG_HIST BEEP CORRECT NO_CASE_GLOB PROMPT_SUBST

        zstyle ':completion:*' menu select
        zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
        zstyle ':completion:*:descriptions' format '%F{yellow}%d%f'

        source ${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh
        HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='fg=white,bg=8'
        HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='fg=white,bg=8'
        HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
        for keymap in viins vicmd; do
          bindkey -M "$keymap" '^[[A' history-substring-search-up
          bindkey -M "$keymap" '^[[B' history-substring-search-down
          bindkey -M "$keymap" '^[OA' history-substring-search-up
          bindkey -M "$keymap" '^[OB' history-substring-search-down
        done
        unset keymap
        bindkey -M viins '^[[Z' autosuggest-accept

        zle_highlight=('region:fg=white,bg=8,bold')
        autoload -Uz add-zle-hook-widget add-zsh-hook

        _fish_style_cursor() {
          printf '\e[2 q'
        }
        add-zle-hook-widget line-init _fish_style_cursor
        add-zle-hook-widget keymap-select _fish_style_cursor

        _fish_style_prompt() {
          local prompt_pwd=$PWD
          if [[ $prompt_pwd == "$HOME" || $prompt_pwd == "$HOME/"* ]]; then
            prompt_pwd="~''${prompt_pwd#"$HOME"}"
          fi
          prompt_pwd=''${prompt_pwd//[[:cntrl:]]/}

          local -a parts=("''${(@s:/:)prompt_pwd}")
          local i
          for (( i = 1; i < ''${#parts}; ++i )); do
            if [[ ''${parts[i]} == .* ]]; then
              parts[i]=''${parts[i][1,2]}
            else
              parts[i]=''${parts[i][1]}
            fi
          done
          prompt_pwd=''${(j:/:)parts}
          PROMPT=$'%B%F{cyan}'"''${prompt_pwd//\%/%%}"$'%b%f\n%K{white}%F{black} %n %f%k%F{white} %f'
        }
        add-zsh-hook precmd _fish_style_prompt
      '';
    };
  };
  xdg.configFile = {
    "nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink (targetDir + "/module/shared/config/nvim");
      recursive = true;
    };
    "vim" = {
      source = config.lib.file.mkOutOfStoreSymlink (targetDir + "/module/shared/config/vim");
      recursive = true;
    };
  };
}
