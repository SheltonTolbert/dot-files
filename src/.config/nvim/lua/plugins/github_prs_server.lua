return {
    name = "github_prs",
    capabilities = {
        tools = {
            {
                name = "list_pull_requests",
                description = "List all open pull requests in a GitHub repository",
                inputSchema = {
                    type = "object",
                    properties = {
                        repo = {
                            type = "string",
                            description = "GitHub repository name (e.g., owner/repo)"
                        }
                    },
                    required = { "repo" }
                },
                handler = function(req, res)
                    local repo = req.params.repo
                    local command = string.format("gh pr list --repo %s --json title,author,status", repo)
                    local output = vim.fn.system(command)

                    if vim.v.shell_error ~= 0 then
                        return res:error("Failed to fetch pull requests. Ensure the repository exists and `gh` CLI is configured.")
                    end

                    local success, prs = pcall(vim.json.decode, output)
                    if not success then
                        return res:error("Failed to parse pull request data.")
                    end

                    local response = {}
                    for _, pr in ipairs(prs) do
                        table.insert(response, string.format("Title: %s\nAuthor: %s\nStatus: %s", pr.title, pr.author.login, pr.status))
                    end

                    return res:text(table.concat(response, "\n\n")):send()
                end
            }
        }
    }
}