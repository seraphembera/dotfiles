return {
  "folke/snacks.nvim",
  opts = function(_, opts)
    -- 确保 terminal 配置表存在，不破坏其他 snacks 配置
    opts.terminal = opts.terminal or {}
    opts.terminal.win = opts.terminal.win or {}
    opts.picker = opts.picker or {}
    opts.picker.sources = opts.picker.sources or {}
    opts.picker.sources.explorer = opts.picker.sources.explorer or {}
    opts.picker.sources.explorer.win = opts.picker.sources.explorer.win or {}
    opts.picker.sources.explorer.win.list = opts.picker.sources.explorer.win.list or {}
    opts.picker.sources.explorer.win.list.keys = opts.picker.sources.explorer.win.list.keys or {}
    
    -- 仅修改为浮动窗口，保留所有其他默认设置（快捷键、行为等）
    opts.terminal.win.style = "float"
    
    -- 可选：浮动窗口外观微调（不影响功能）
    opts.terminal.win.border = "rounded"  -- 边框：rounded, single, double
    opts.terminal.win.backdrop = 100      -- 背景暗化（0-100，100为不透明）
    -- opts.terminal.win.height = 0.8     -- 高度 80%（可选，默认自适应）
    -- opts.terminal.win.width = 0.8      -- 宽度 80%（可选，默认自适应）

    -- o 键执行 confirm 动作（与 Enter 完全相同：文件打开，文件夹展开/折叠）
    opts.picker.sources.explorer.win.list.keys["o"] = "confirm"
    
    return opts
  end,
}