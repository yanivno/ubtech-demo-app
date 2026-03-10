# GitHub Copilot Coding Agent Instructions

## Pull Request Behavior

When invoked via `@copilot` in a comment on an existing pull request:

1. **Always work within the existing PR** — Do NOT create a new pull request
2. **Push commits directly to the existing PR's branch** — Add your changes as new commits to the branch associated with the current PR
3. **Reply as a comment on the PR** — Provide your response, explanation, or status update as a comment on the same PR thread where you were invoked
4. **Reference the original comment** — When responding, acknowledge the specific request from the comment that triggered you

## What NOT to Do

- Do NOT open a new pull request when responding to a comment on an existing PR
- Do NOT create a new branch unless explicitly requested
- Do NOT close the existing PR and open a new one

## Commit Messages

When pushing commits to an existing PR:
- Use clear, descriptive commit messages
- Reference the PR number in the commit message when relevant
- Keep commits atomic and focused on the requested change
