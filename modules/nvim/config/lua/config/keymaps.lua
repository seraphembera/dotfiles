local map = require("lazyvim.util").safe_keymap_set

-- jk 退出插入模式
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })
-- Shift+j/k 跳跃 5 行
map("n", "<S-j>", "5j", { desc = "Jump 5 lines down" })
map("n", "<S-k>", "5k", { desc = "Jump 5 lines up" })