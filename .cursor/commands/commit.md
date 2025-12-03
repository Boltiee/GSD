You are operating inside a Git-enabled project. Perform the following steps:

1. Detect the current branch name.
2. Stage all updated, new, and deleted files:
   `git add -A`

3. Generate a clear, concise commit message summarizing:
   - what changed in the staged files,
   - why the change was made (infer if needed),
   - written in imperative tone (e.g., “Add…”, “Fix…”, “Refactor…”).

4. Commit using the generated message:
   `git commit -m "<MESSAGE>"`

5. Push the new commit to the current branch:
   `git push`

6. After pushing, output a confirmation message such as:
   “✅ Changes committed and pushed to <branch-name>.”

If no changes exist, output:
“ℹ️ No changes to commit.”
