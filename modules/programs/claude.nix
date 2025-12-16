# Claude Code configuration (uses built-in home-manager module)
{ config, lib, pkgs, ... }:

{
  programs.claude-code = {
    enable = true;
    settings.statusLine = {
      type = "command";
      command = "~/.claude/statusline.sh";
    };
  };

  # Custom status line script
  home.file.".claude/statusline.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      # Parse JSON input from Claude Code
      input=$(cat)
      model=$(echo "$input" | ${pkgs.jq}/bin/jq -r '.model.display_name // "Claude"')
      cwd=$(echo "$input" | ${pkgs.jq}/bin/jq -r '.cwd // "."')
      cost=$(echo "$input" | ${pkgs.jq}/bin/jq -r '.cost.total_cost_usd // 0')

      # Context window info
      input_tokens=$(echo "$input" | ${pkgs.jq}/bin/jq -r '.context_window.total_input_tokens // 0')
      output_tokens=$(echo "$input" | ${pkgs.jq}/bin/jq -r '.context_window.total_output_tokens // 0')
      context_size=$(echo "$input" | ${pkgs.jq}/bin/jq -r '.context_window.context_window_size // 200000')

      # Calculate total tokens and format as K
      total_tokens=$((input_tokens + output_tokens))
      tokens_k=$(echo "scale=1; $total_tokens / 1000" | ${pkgs.bc}/bin/bc)
      context_k=$(echo "scale=0; $context_size / 1000" | ${pkgs.bc}/bin/bc)

      # Format cost
      cost_fmt=$(printf "%.4f" "$cost")

      # Get git status if in a git repo
      git_info=""
      if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
        branch=$(git -C "$cwd" branch --show-current 2>/dev/null)

        # Check for uncommitted changes
        if ! git -C "$cwd" diff --quiet 2>/dev/null || ! git -C "$cwd" diff --cached --quiet 2>/dev/null; then
          dirty="*"
        else
          dirty=""
        fi

        # Check for untracked files
        if [ -n "$(git -C "$cwd" ls-files --others --exclude-standard 2>/dev/null)" ]; then
          untracked="+"
        else
          untracked=""
        fi

        git_info="\033[33m$branch$dirty$untracked\033[0m "
      fi

      # Output status line with colors
      echo -e "$git_info\033[36m$model\033[0m \033[35m''${tokens_k}K/''${context_k}K\033[0m \033[32m\$$cost_fmt\033[0m"
    '';
  };
}
