---
name: create-pr
description: Create a pull request with Jira context, conventional commit title, and filled-out PR template.
user-invokable: true
disable-model-invocation: true
---

# Create Pull Request

You are a PR creation assistant. Follow these steps exactly.

## Step 1 — Gather git context

Run these commands **in parallel** using the Bash tool:

1. `git branch --show-current`
2. `git log main..HEAD --oneline`
3. `git diff main...HEAD --stat`
4. `git diff main...HEAD`

Then run `git status --short` to check for uncommitted changes.

**Abort conditions:**
- If on `main` branch → tell the user: "You're on main. Create a feature branch first." and stop.
- If `git diff main...HEAD` is empty (no diff) → tell the user: "No changes found relative to main." and stop.
- If there are uncommitted changes → warn the user and ask them to commit first before proceeding.

## Step 2 — Extract Jira ticket from branch name

Parse the branch name with pattern `^([A-Za-z]+-\d+)` to extract the Jira ticket key.

- The branch format is `<project>-<number>` in lowercase (e.g., `shep-888`).
- Uppercase it to form the Jira key (e.g., `SHEP-888`).
- If no match is found, set `jiraKey = null` and skip Step 3.

## Step 3 — Fetch Jira details

Only run this step if `jiraKey` is not null.

1. Call the `getAccessibleAtlassianResources` Atlassian MCP tool to get the `cloudId`.
2. Call the `getJiraIssue` Atlassian MCP tool with:
   - `cloudId`: from step above
   - `issueIdOrKey`: the Jira key (e.g., `SHEP-888`)
   - `fields`: `["summary", "description", "issuetype"]`

**If Jira fails for any reason** (auth error, network issue, ticket not found), log a note and proceed without Jira context. Never block PR creation because of Jira.

## Step 4 — Generate PR title

Format:
```
[SHEP-XXX] <type>: <short description>
```

If no Jira ticket was found, omit the `[SHEP-XXX]` prefix.

**Conventional commit types** — pick the one that best fits the diff:
- `feat` — new feature or capability
- `fix` — bug fix
- `refactor` — restructuring without behavior change
- `chore` — maintenance, deps, config
- `docs` — documentation only
- `test` — adding or updating tests
- `style` — formatting, linting, no logic change
- `revert` — reverting a previous change

**Description source:**
- If Jira summary is available, distill it into a concise description.
- Otherwise, derive from commit messages and diff content.

**Keep the total title under 70 characters.**

## Step 5 — Generate PR body

Fill out the PR body following this exact template structure. Read the project's `PULL_REQUEST_TEMPLATE.md` if you haven't already to confirm the format.

### References
```
[SHEP-XXX](https://mozilla-hub.atlassian.net/browse/SHEP-XXX)
```
If no Jira ticket, write "N/A".

### Problem Statement
- 2-4 sentences explaining **why** this change is needed.
- Distill from the Jira description if available; do NOT copy it verbatim.
- If no Jira context, derive from the diff and commit messages.

### Proposed Changes
- 3-7 bullet points.
- Group by **logical change**, not per-file.
- Only mention decisions that aren't obvious from reading the code.
- No line-by-line walkthrough.

### Verification Steps
- Numbered manual steps with expected results.
- Cover edge cases and important scenarios.
- Do NOT include: "run tests", "run linter", "run the app", or "check CI" — those are assumed.

### Check list before merging
Include this checklist **verbatim** — never modify it:
```markdown
- [ ] Double check that you have complete code coverage for any code you have added or edited in this PR.
- [ ] Double-check if this PR needs to test any sections in our [runbook for regressions](https://github.com/mozilla-services/consvc-shepherd/blob/main/docs/RegressionTestRunbook.md). If so, make sure to note them in the verification steps.
```

### Revert readiness
- 1-2 sentences.
- Flag migrations, batch job side effects, or anything that makes reverting non-trivial.
- If safe to revert, say so plainly.

### Visuals
- If the diff contains frontend changes (React components, templates, CSS) → ask the user to provide screenshots and leave a placeholder.
- If there are no UI changes → **remove this section entirely** from the PR body.

## Step 6 — Preview and confirm

Show the user the full PR as a preview with the title and body clearly formatted. Use a markdown code block or quote block so they can read it easily.

Ask the user: "Does this look good? You can request edits or say 'yes' to create the PR."

- If the user requests edits, apply them and show the updated preview again.
- Only proceed to Step 7 when the user explicitly approves.

## Step 7 — Push and create

1. Check if the branch has an upstream remote. If not, push with:
   ```
   git push -u origin HEAD
   ```
2. Create the PR:
   ```
   gh pr create --title "<title>" --body "<body>"
   ```
   Use a HEREDOC for the body to preserve formatting:
   ```
   gh pr create --title "<title>" --body "$(cat <<'EOF'
   <body content>
   EOF
   )"
   ```
3. Output the PR URL to the user.

## Error Handling

| Scenario | Action |
|----------|--------|
| On `main` branch | Abort with message |
| No diff vs main | Abort with message |
| Uncommitted changes | Warn, ask user to commit first |
| Jira unavailable / auth error | Proceed without Jira context |
| `gh` not authenticated | Tell user to run `gh auth login` |
| Push fails | Show error, suggest `git pull --rebase` |
