return {
  "tinted-theming/tinted-vim",
  name = "tinted",
  priority = 1000,
  config = function()
    vim.cmd.colorscheme "base16-horizon-dark"
  end
}
