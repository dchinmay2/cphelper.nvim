local sep = package.config:sub(1, 1)

local M = {}

--- Edit a test case
--- @param case string Test case no.
function M.edittc(case)
    vim.cmd("tabe output" .. case)
    vim.cmd("vsplit input" .. case)
end

--- Delete test cases
--- @param cases string[] Test case nos.
function M.deletetc(cases)
    for _, case in pairs(cases) do
        vim.fn.delete(vim.fn.getcwd() .. sep .. "input" .. case)
        vim.fn.delete(vim.fn.getcwd() .. sep .. "output" .. case)
    end
end

return M
