local nvim_create_user_command = vim.api.nvim_create_user_command

nvim_create_user_command("CphReceive", function()
    require("cphelper.receive").receive()
end, {})

nvim_create_user_command("CphStop", function()
    require("cphelper.receive").stop()
end, {})

nvim_create_user_command("CphTest", function(args)
    vim.cmd.lcd({ "%:p:h", mods = {silent = true }})
    require("cphelper.process_tests").process(args.fargs)
end, { nargs = "*" })

nvim_create_user_command("CphRetest", function(args)
    vim.cmd.lcd({ "%:p:h", mods = {silent = true }})
    require("cphelper.process_tests").process_retests(args.fargs)
end, { nargs = "*" })

nvim_create_user_command("CphEdit", function(args)
    vim.cmd.lcd({ "%:p:h", mods = {silent = true }})
    require("cphelper.modify_tc").edittc(args.fargs[1])
end, { nargs = 1 })

nvim_create_user_command("CphDelete", function(args)
    vim.cmd.lcd({ "%:p:h", mods = {silent = true }})
    require("cphelper.modify_tc").deletetc(args.fargs)
end, { nargs = "+" })

vim.api.nvim_set_hl(0, "CphUnderline", { underline = 1 })
