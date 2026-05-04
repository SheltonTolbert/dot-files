local _99 = require("99")

-- 99 does not ship a Codex provider yet, so implement its provider contract here.
local function get_context(request)
    return request.context or request
end

local function once(fn)
    local called = false

    return function(...)
        if called then
            return
        end

        called = true
        fn(...)
    end
end

local CodexProvider = {}

function CodexProvider:_get_provider_name()
    return "CodexProvider"
end

function CodexProvider._get_default_model()
    return vim.g.codex_99_model or vim.env.CODEX_MODEL or "default"
end

function CodexProvider:_build_command(query, request)
    local context = get_context(request)
    local cmd = {
        "codex",
        "--ask-for-approval",
        "never",
        "exec",
        "--cd",
        vim.uv.cwd(),
        "--sandbox",
        "workspace-write",
        "--skip-git-repo-check",
        "--color",
        "never",
    }

    if context.model and context.model ~= "" and context.model ~= "default" then
        vim.list_extend(cmd, { "--model", context.model })
    end

    table.insert(cmd, query)

    return cmd
end

function CodexProvider:_retrieve_response(request)
    local context = get_context(request)
    local logger = context.logger:set_area(self:_get_provider_name())
    local success, result = pcall(function()
        return vim.fn.readfile(context.tmp_file)
    end)

    if not success then
        logger:error(
            "retrieve_results: failed to read file",
            "tmp_name",
            context.tmp_file,
            "error",
            result
        )
        return false, ""
    end

    local response = table.concat(result, "\n")
    logger:debug("retrieve_results", "results", response)

    return true, response
end

function CodexProvider:make_request(query, request, observer)
    local context = get_context(request)
    local logger = context.logger:set_area(self:_get_provider_name())

    observer = observer or {}

    if observer.on_start then
        observer.on_start()
    end

    local once_complete = once(function(status, text)
        if observer.on_complete then
            observer.on_complete(status, text)
        end
    end)

    local command = self:_build_command(query, request)
    logger:debug("make_request", "tmp_file", context.tmp_file)
    logger:debug("make_request", "command", command)

    local stdout_chunks = {}
    local stderr_chunks = {}

    local proc = vim.system(
        command,
        {
            text = true,
            stdout = vim.schedule_wrap(function(err, data)
                logger:debug("stdout", "data", data)
                if request.is_cancelled and request:is_cancelled() then
                    once_complete("cancelled", "")
                    return
                end
                if err and err ~= "" then
                    logger:debug("stdout#error", "err", err)
                end
                if not err and data then
                    table.insert(stdout_chunks, data)
                    if observer.on_stdout then
                        observer.on_stdout(data)
                    end
                end
            end),
            stderr = vim.schedule_wrap(function(err, data)
                logger:debug("stderr", "data", data)
                if request.is_cancelled and request:is_cancelled() then
                    once_complete("cancelled", "")
                    return
                end
                if err and err ~= "" then
                    logger:debug("stderr#error", "err", err)
                end
                if not err and data then
                    table.insert(stderr_chunks, data)
                    if observer.on_stderr then
                        observer.on_stderr(data)
                    end
                end
            end),
        },
        vim.schedule_wrap(function(obj)
            if request.is_cancelled and request:is_cancelled() then
                once_complete("cancelled", "")
                logger:debug("on_complete: request has been cancelled")
                return
            end

            if obj.code ~= 0 then
                local error_message = string.format(
                    "process exit code: %d\nstdout:\n%s\nstderr:\n%s\n%s",
                    obj.code,
                    table.concat(stdout_chunks, ""),
                    table.concat(stderr_chunks, ""),
                    vim.inspect(obj)
                )
                once_complete("failed", error_message)
                logger:error(
                    self:_get_provider_name() .. " make_query failed",
                    "obj from results",
                    obj,
                    "stdout",
                    stdout_chunks,
                    "stderr",
                    stderr_chunks
                )
                return
            end

            vim.schedule(function()
                local ok, response = self:_retrieve_response(request)
                if ok then
                    once_complete("success", response)
                else
                    once_complete("failed", "unable to retrieve response from temp file")
                end
            end)
        end)
    )

    if request._set_process then
        request:_set_process(proc)
    elseif context._set_process then
        context:_set_process(proc)
    end
end

local cwd = vim.uv.cwd()
local basename = vim.fs.basename(cwd)
local provider = CodexProvider

if vim.fn.executable("codex") ~= 1 then
    provider = _99.Providers.OpenCodeProvider
    vim.notify("codex CLI not found; 99 is using OpenCodeProvider", vim.log.levels.WARN)
end

_99.setup({
    provider = provider,

    logger = {
        level = _99.DEBUG,
        path = "/tmp/" .. basename .. ".99.debug",
        print_on_error = true,
    },

    completion = {
        files = {},
        source = "cmp",
    },

    md_files = {
        "AGENT.md",
    },
})
