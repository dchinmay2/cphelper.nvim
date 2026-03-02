local run = require("cphelper.run_test")
local def = require("cphelper.definitions")

--- Run multiple test cases by calling `"cphelper.run_test".run_test()` on a binary
---@param case_numbers table #list of case numbers
---@return integer #number of cases passed
---@return integer #total number of cases
---@return table #result to be displayed (list of lines)
local function iterate_cases(case_numbers)
    local cwd = vim.uv.cwd()
    local ft = vim.filetype.match({ filename = vim.api.nvim_buf_get_name(0) })
    local ac, cases = 0, 0
    local display = {}
    if #case_numbers == 0 then
        for _, input_file in ipairs(vim.fn.glob(cwd .. "/input*", false, true)) do
            local num = input_file:match("input(%d+)$")
            if num then
                local case_display, success = run.run_test(num, def.run_cmd[ft])
                vim.list_extend(display, case_display)
                ac = ac + success -- status is 1 on correct answer, 0 otherwise
                cases = cases + 1
            end
        end
    else
        for _, case in ipairs(case_numbers) do
            local case_display, success = run.run_test(case, def.run_cmd[ft])
            vim.list_extend(display, case_display)
            ac = ac + success
            cases = cases + 1
        end
    end
    return ac, cases, display
end

--- Display results
---@param ac integer #no. of cases passed
---@param cases integer #total no. of cases
---@param display table #result to be displayed (list of lines)
local function display_results(ac, cases, display)
    local header = "   RESULTS: " .. ac .. "/" .. cases .. " AC"
    if ac == cases then
        header = header .. " 🎉🎉"
    end
    local contents = { "", header, "" }
    for _, line in ipairs(display) do
        table.insert(contents, line)
    end
    local bufnr = require("cphelper.helpers").display_right(contents)
    vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
    vim.api.nvim_set_option_value("filetype", "Results", { buf = bufnr })
    local highlights = {
        ["Status: AC"] = "DiffAdd",
        ["Status: WA"] = "Error",
        ["Status: RTE"] = "Error",
        ["Case #\\d\\+"] = "DiffChange",
        ["Input:"] = "CphUnderline",
        ["Expected output:"] = "CphUnderline",
        ["Received output:"] = "CphUnderline",
        ["Error:\n"] = "CphUnderline",
    }
    for match, group in pairs(highlights) do
        vim.fn.matchadd(group, match)
    end
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<esc>", "<cmd>bd<CR>", { noremap = true })
    vim.api.nvim_buf_set_keymap(bufnr, "n", "q", "<cmd>bd<CR>", { noremap = true })
end

local M = {}

--- Compile and test
--- @param args string[] #case numbers to test. If not provided, then all cases are tested
function M.process(args)
    local ft = vim.filetype.match({ filename = vim.api.nvim_buf_get_name(0) })
    if def.compile_cmd[ft] ~= nil then
        vim.system((vim.g["cph#" .. ft .. "#compile_command"] or def.compile_cmd[ft]), {}, function(out)
            if out.stderr then
                vim.schedule(function() vim.api.nvim_echo({ { out.stderr } }, true, { err = true }) end)
            end
            if out.code == 0 then
                vim.schedule(function()
                    local ac, cases, results = iterate_cases(args)
                    display_results(ac, cases, results)
                end)
            end
        end)
    else
        M.process_retests(args)
    end
end

--- Retest without compiling
--- @param args string[] #case numbers to test. If not provided, then all cases are tested
function M.process_retests(args)
    local ac, cases, display = iterate_cases(args)
    display_results(ac, cases, display)
end

return M
