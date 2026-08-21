return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    config = function()
      local langs = {
        "bash",
        "c",
        "caddy",
        "cmake",
        "css",
        "dart",
        "diff",
        "dockerfile",
        "fish",
        "git_rebase",
        "gitcommit",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "nix",
        "ocaml",
        "python",
        "rust",
        "svelte",
        "toml",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      }
      local ts = require("nvim-treesitter")
      local installed = ts.get_installed("parsers")
      local missing = {}
      for _, lang in pairs(langs) do
        if not vim.tbl_contains(installed, lang) then
          table.insert(missing, lang)
        end
      end
      if #missing > 0 then
        ts.install(missing):wait(30000)
      end
      for _, lang in pairs(langs) do
        local fts = vim.treesitter.language.get_filetypes(lang)
        vim.api.nvim_create_autocmd("FileType", {
          pattern = fts,
          callback = function(args)
            local bufnr = args.buf
            vim.treesitter.start(bufnr)
            vim.bo[bufnr].syntax = "on"
            vim.wo.foldlevel = 99
            vim.wo.foldmethod = "expr"
            vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
            vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end,
        })
      end
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter-textobjects").setup {
        select = {
          lookahead = true,
          selection_modes = {
            ["@parameter.outer"] = "v",
            ["@function.outer"] = "V",
          },
          include_surrounding_whitespace = false,
        },
      }

      local select = require("nvim-treesitter-textobjects.select").select_textobject
      local map = function(keys, query, group)
        group = group or "textobjects"
        vim.keymap.set({ "x", "o" }, keys, function()
          select(query, group)
        end)
      end

      map("af", "@function.outer")
      map("if", "@function.inner")
      map("ac", "@class.outer")
      map("ic", "@class.inner")
      map("as", "@local.scope", "locals")
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = "BufReadPost",
    opts = {
      enable = true,
      max_lines = 3,
      multiline_threshold = 5,
      mode = "cursor",
    },
  },
  {
    "saghen/blink.cmp",
    dependencies = {
      "folke/lazydev.nvim",
      "rafamadriz/friendly-snippets",
    },
    version = "1.*",
    opts = {
      sources = {
        default = { "lazydev", "lsp", "path", "snippets", "buffer" },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
        }
      },
      completion = {
        list = { selection = { preselect = true, auto_insert = false } },
        menu = {
          auto_show = function(ctx)
            return ctx.mode ~= "cmdline"
          end,
          draw = {
            columns = {
              { "label", "label_description", gap = 1 },
              { "kind" },
            },
          },
        },
        documentation = { auto_show = true, auto_show_delay_ms = 0 },
      },
      keymap = {
        preset = "none",
        ["<c-p>"] = { "select_prev", "fallback" },
        ["<c-n>"] = { "select_next", "fallback" },
        ["<c-u>"] = { "scroll_documentation_down", "fallback" },
        ["<c-d>"] = { "scroll_documentation_up", "fallback" },
        ["<c-space>"] = {
          "show",
          "hide",
        },
        ["<tab>"] = {
          "accept",
          "fallback",
        },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "saghen/blink.cmp" },
    config = function()
      local servers = {
        bashls = {},
        cssls = {
          settings = {
            css = {
              validate = true,
              lint = {
                unknownAtRules = "ignore",
              },
            },
          },
        },
        clangd = {
          filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "hpp" },
        },
        docker_compose_language_service = {},
        dockerls = {},
        gopls = {},
        html = {},
        jsonls = {},
        lua_ls = {
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
            },
          },
        },
        nixd = {},
        ocamllsp = {},
        ruff = {},
        rust_analyzer = {},
        svelte = {},
        tailwindcss = {},
        taplo = {},
        texlab = {},
        ts_ls = {
          init_options = {
            preferences = {
              importModuleSpecifierPreference = "non-relative",
            },
          },
        },
        ty = {
          cmd = { "ty", "server" },
        },
        yamlls = {},
        zls = {},
      }

      for server_id, server_config in pairs(servers) do
        local M = {}
        vim.lsp.config(server_id,
          vim.tbl_deep_extend("keep", server_config, {
            capabilities = require("blink.cmp").get_lsp_capabilities(
              server_config.capabilities
            ),
            on_init = function(client)
              if client.server_capabilities then
                client.server_capabilities.semanticTokensProvider = nil
              end
            end,
            handlers = {
              ["experimental/serverStatus"] = function(_, result, ctx, _)
                if result.quiescent and not M.ran_once then
                  for _, bufnr in
                  ipairs(vim.lsp.get_buffers_by_client_id(ctx.client_id))
                  do
                    vim.lsp.inlay_hint.enable(false, {
                      bufnr = bufnr,
                    })
                    vim.lsp.inlay_hint.enable(true, {
                      bufnr = bufnr,
                    })
                  end
                  M.ran_once = true
                end
              end,
            },
            on_attach = function(client, bufnr)
              if client.server_capabilities.inlayHintProvider then
                vim.lsp.inlay_hint.enable(true, {
                  bufnr = bufnr,
                })
              end
              vim.keymap.set(
                "n",
                "<leader>ca",
                vim.lsp.buf.code_action,
                { desc = "[C]ode [A]ction" }
              )
              vim.keymap.set(
                "n",
                "gd",
                vim.lsp.buf.definition,
                { desc = "[G]oto [D]efinition" }
              )
              vim.keymap.set(
                "n",
                "<c-k>",
                vim.lsp.buf.signature_help,
                { desc = "Signature Documentation" }
              )
              vim.keymap.set(
                "n",
                "K",
                vim.lsp.buf.hover,
                { desc = "Hover Documentation" }
              )
            end,
          })
        )
        vim.lsp.enable(server_id)
      end
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        caddyfile = {
          command = "caddy",
          args = { "fmt", "-" },
        },
        ["tex-fmt"] = {
          args = { "--stdin", "--nowrap" },
        },
      },
      formatters_by_ft = {
        bash = { "shfmt" },
        c = { "clang-format" },
        caddyfile = { "caddyfile" },
        cmake = { "cmake_format" },
        conf = { "shfmt" },
        cpp = { "clang-format" },
        css = { "prettierd" },
        dart = { "dart_format" },
        fish = { "fish_indent" },
        hcl = { "hcl" },
        javascript = { "prettierd" },
        javascriptreact = { "prettierd" },
        json = { "prettierd" },
        jsonc = { "prettierd" },
        just = { "just" },
        lua = { "stylua" },
        markdown = { "prettierd" },
        nix = { "nixfmt" },
        ocaml = { "ocamlformat" },
        python = {
          "ruff_fix",
          "ruff_format",
          "ruff_organize_imports",
        },
        sh = { "shfmt" },
        svelte = { "prettierd" },
        tex = { "tex-fmt" },
        typescript = { "prettierd" },
        typescriptreact = { "prettierd" },
        rust = { "rustfmt" },
        yaml = { "prettierd" },
      },
      format_on_save = {
        timeout_ms = 1000,
        lsp_format = "fallback",
      },
    },
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    "github/copilot.vim",
    config = function()
      vim.keymap.set('i', '<s-tab>', 'copilot#Accept("\\<CR>")', {
        expr = true,
        replace_keycodes = false
      })
      vim.g.copilot_no_tab_map = true
    end
  },
}
