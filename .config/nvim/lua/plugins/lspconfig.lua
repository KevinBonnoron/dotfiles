return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "lspcontainers/lspcontainers.nvim",
  },
  cond = function()
    return vim.fn.executable("docker") == 1
  end,
  config = function()
    local lspconfig = require("lspconfig")
    local lspcontainers = require('lspcontainers')

    -- Fonction helper pour configurer les serveurs
    local function setup_lsp(server_name, config)
      local default_config = {
        before_init = function(params)
          params.processId = vim.NIL
        end,
        cmd = lspcontainers.command(server_name),
        root_dir = function()
          -- Forcer le répertoire courant comme racine
          return vim.fn.getcwd()
        end,
      }

      lspconfig[server_name].setup(vim.tbl_deep_extend("force", default_config, config or {}))
    end

    -- Configuration des serveurs
    setup_lsp("lua_ls", {
      settings = {
        Lua = {
          runtime = {
            version = "LuaJIT",
          },
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            library = {
              vim.api.nvim_get_runtime_file("", true),
              vim.fn.expand("~/.local/share/nvim/lazy"),
            },
            checkThirdParty = false,
            maxPreload = 1000,
            preloadFileSize = 1000,
          },
          telemetry = {
            enable = false,
          },
          format = {
            enable = true,
          },
        },
      },
    })

    setup_lsp('tsserver')
    --setup_lsp('angularls')
    setup_lsp('html')
    setup_lsp('jsonls')
    setup_lsp('yamlls')
    setup_lsp('tailwindcss', {
      filetypes = {
        "css", "postcss", "sass", "scss", "stylus",
        "html", "javascript", "typescript", "vue", "svelte"
      },
    })

    vim.keymap.set("n", "<C- F12>", function() vim.lsp.buf.impletations() end, { desc = "List implementations" })
    vim.keymap.set({ "n", "i", "v" }, "<A-F>", function() vim.lsp.buf.format({ async = true }) end,
      { desc = "Format code" })
  end,
}
