local M = {}
local api = vim.api

--- Strip out special characters from a string
--- @param s string The string to sanitize
--- @return string
function M.sanitize(s)
    local copy = s
    local unwanted = { "-", " ", "#", "%.", ":", "'", "+", "%%" }
    for _, char in pairs(unwanted) do
        local pos = string.find(copy, char)
        while pos do
            copy = string.sub(copy, 1, pos - 1) .. string.sub(copy, pos + 1)
            pos = string.find(copy, char)
        end
    end
    return copy
end

--- Compare two lists of strings
--- @param t1 table The first table
--- @param t2 table The second table
--- @return string
function M.compare_str_list(t1, t2)
    local compare = function(str1, str2)
        if str1 == str2 then
            return "yes"
        elseif str1:gsub("%s*$", "") == str2:gsub("%s*$", "") then
            return "trailing"
        else
            return "no"
        end
    end

    if #t1 ~= #t2 then
        return "no"
    end

    local trailing_match = false
    for k, _ in pairs(t1) do
        local matches = compare(t1[k], t2[k])
        if matches == "no" then
            return "no"
        elseif matches == "trailing" then
            trailing_match = true
        end
    end

    if trailing_match then
        return "trailing"
    else
        return "yes"
    end
end

--- Pad a list of lines with spaces
--- Copied from neovim master.
--- Credits: Christian Clason and Hirokazu Hata
--- @param contents table
--- @param opts table?
local function pad(contents, opts)
    vim.validate("contents", contents, "table")
    vim.validate("opts", opts, "table", true)
    opts = opts or {}
    local left_padding = (" "):rep(opts.pad_left or 1)
    local right_padding = (" "):rep(opts.pad_right or 1)
    for i, line in ipairs(contents) do
        contents[i] = string.format("%s%s%s", left_padding, line:gsub("\r", ""), right_padding)
    end
    if opts.pad_top then
        for _ = 1, opts.pad_top do
            table.insert(contents, 1, "")
        end
    end
    if opts.pad_bottom then
        for _ = 1, opts.pad_bottom do
            table.insert(contents, "")
        end
    end
    return contents
end

--- Display the results in a floating window on the right side
--- @param contents table List of lines to display
--- @return integer # bufnr of the created window
function M.display_right(contents)
    local bufnr = api.nvim_create_buf(false, true)
    local width = 0
    for _, value in pairs(contents) do
        width = math.max(width, string.len(value))
    end
    width = width + 5
    local height = math.floor(vim.o.lines * 0.9)
    if not vim.g["cph#vsplit"] then
        api.nvim_open_win(bufnr, true, {
            border = vim.g["cph#border"] or "rounded",
            style = "minimal",
            relative = "editor",
            row = math.floor(((vim.o.lines - height) / 2) - 1),
            col = math.floor(vim.o.columns - width - 1),
            width = width,
            height = height,
        })
    else
        vim.cmd("vsplit")
        api.nvim_win_set_buf(0, bufnr)
        api.nvim_win_set_width(0, width)
        api.nvim_set_option_value("number", false, { win = 0 })
        api.nvim_set_option_value("relativenumber", false, { win = 0 })
        api.nvim_set_option_value("cursorline", false, { win = 0 })
        api.nvim_set_option_value("cursorcolumn", false, { win = 0 })
        api.nvim_set_option_value("spell", false, { win = 0 })
        api.nvim_set_option_value("list", false, { win = 0 })
        api.nvim_set_option_value("signcolumn", "auto", { win = 0 })
    end
    contents = pad(contents, { pad_top = 1 })
    api.nvim_set_option_value("foldmethod", "indent", { win = 0 })
    api.nvim_buf_set_lines(bufnr, 0, -1, true, contents)
    api.nvim_set_option_value("shiftwidth", 2, { buf = bufnr })
    return bufnr
end

return M
