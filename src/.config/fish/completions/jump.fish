# jump fish shell completion

function __fish_jump_no_subcommand --description 'Test if there has been any subcommand yet'
    for i in (commandline -opc)
        if contains -- $i describe review status config completion fish help h bash zsh help h help h
            return 1
        end
    end
    return 0
end

complete -c jump -n '__fish_jump_no_subcommand' -f -l help -s h -d 'show help'
complete -c jump -n '__fish_jump_no_subcommand' -f -l help -s h -d 'show help'
complete -c jump -n '__fish_seen_subcommand_from describe' -f -l help -s h -d 'show help'
complete -r -c jump -n '__fish_jump_no_subcommand' -a 'describe' -d '[34m[READ] [0mDraft a PR title/body and create or update a GitHub PR'
complete -c jump -n '__fish_seen_subcommand_from describe' -f -l br -s b -r -d 'Optional. Branch to describe; uses the current branch if omitted'
complete -c jump -n '__fish_seen_subcommand_from describe' -f -l pr -s p -r -d 'Optional. Existing GitHub PR number or URL to update instead of creating a new PR'
complete -c jump -n '__fish_seen_subcommand_from describe' -f -l llm -s l -r -d 'Optional. LLM to use (options: claude, gemini, codex, opencode)'
complete -c jump -n '__fish_seen_subcommand_from review' -f -l help -s h -d 'show help'
complete -r -c jump -n '__fish_jump_no_subcommand' -a 'review' -d '[34m[READ] [0mReview a GitHub PR and generate actionable feedback'
complete -c jump -n '__fish_seen_subcommand_from review' -f -l pr -s p -r -d 'Required. GitHub PR number or PR URL to review'
complete -c jump -n '__fish_seen_subcommand_from review' -f -l llm -s l -r -d 'LLM to use. One for standard, two (comma-separated) for discussion/adversarial: claude, gemini, codex, opencode'
complete -c jump -n '__fish_seen_subcommand_from review' -f -l mode -r -d 'Review mode: single (default), discuss (3-round debate), full (specialist pipeline)'
complete -c jump -n '__fish_seen_subcommand_from review' -f -l specialists -r -d 'Full mode only. auto (detect from diff), all, or comma-separated: security,ecto,liveview,...'
complete -c jump -n '__fish_seen_subcommand_from status' -f -l help -s h -d 'show help'
complete -r -c jump -n '__fish_jump_no_subcommand' -a 'status' -d '[34m[READ] [0mDraft a daily standup update based on recent activity'
complete -c jump -n '__fish_seen_subcommand_from status' -f -l since -s s -r -d 'Optional. Override the lookback window (e.g. 24h, 3d, 2026-03-15, 2026-03-15T09:00:00Z)'
complete -c jump -n '__fish_seen_subcommand_from status' -f -l llm -s l -r -d 'Optional. LLM to use (options: claude, gemini, codex, opencode)'
complete -c jump -n '__fish_seen_subcommand_from config' -f -l help -s h -d 'show help'
complete -r -c jump -n '__fish_jump_no_subcommand' -a 'config' -d '[31m[WRITE][0m Interactively configure jump defaults'
complete -c jump -n '__fish_seen_subcommand_from completion' -f -l help -s h -d 'show help'
complete -r -c jump -n '__fish_jump_no_subcommand' -a 'completion' -d 'Generate shell completion scripts'
complete -c jump -n '__fish_seen_subcommand_from completion' -f -l help -s h -d 'show help'
complete -c jump -n '__fish_seen_subcommand_from fish' -f -l help -s h -d 'show help'
complete -r -c jump -n '__fish_seen_subcommand_from completion' -a 'fish' -d 'Generate fish completion script'
complete -c jump -n '__fish_seen_subcommand_from fish' -f -l help -s h -d 'show help'
complete -c jump -n '__fish_seen_subcommand_from help h' -f -l help -s h -d 'show help'
complete -r -c jump -n '__fish_seen_subcommand_from fish' -a 'help h' -d 'Shows a list of commands or help for one command'
complete -c jump -n '__fish_seen_subcommand_from bash' -f -l help -s h -d 'show help'
complete -r -c jump -n '__fish_seen_subcommand_from completion' -a 'bash' -d 'Generate bash completion script'
complete -c jump -n '__fish_seen_subcommand_from zsh' -f -l help -s h -d 'show help'
complete -r -c jump -n '__fish_seen_subcommand_from completion' -a 'zsh' -d 'Generate zsh completion script'
complete -c jump -n '__fish_seen_subcommand_from help h' -f -l help -s h -d 'show help'
complete -r -c jump -n '__fish_seen_subcommand_from completion' -a 'help h' -d 'Shows a list of commands or help for one command'
complete -c jump -n '__fish_seen_subcommand_from help h' -f -l help -s h -d 'show help'
complete -r -c jump -n '__fish_jump_no_subcommand' -a 'help h' -d 'Shows a list of commands or help for one command'
