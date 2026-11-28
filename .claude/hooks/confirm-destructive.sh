#!/usr/bin/env bash
# PreToolUse hook (Bash): force a confirmation prompt for destructive commands.
cmd=$(jq -r '.tool_input.command // empty')
[ -z "$cmd" ] && exit 0

reason=""
decision="ask"
force_add='git[[:space:]](.*[[:space:]])?add([[:space:]].*)?[[:space:]](-[a-zA-Z]*f[a-zA-Z]*|--force)([[:space:]]|$)'
# True if the command names an env file (other than .env.example) or a catch-all (., *, -A, --all).
targets_env_or_all() {
  local w
  for w in $1; do
    w=${w//[\"\']/}
    case "$w" in
      *.env.example) ;;
      .env|.env.*|*/.env|*/.env.*|*.env) return 0 ;;
      .|./|'*'|-A|--all|-[a-zA-Z]*A*) return 0 ;;
    esac
  done
  return 1
}
# --- .env protection (deny, not ask) ---
if grep -qE "$force_add" <<<"$cmd" && targets_env_or_all "$cmd"; then
  decision="deny"; reason="force-adding .env / ignored files to git (git add -f)"
elif grep -qE '\.gitignore' <<<"$cmd" \
   && grep -qE '(sed|perl)[[:space:]].*-[a-zA-Z]*i|[^>]>[[:space:]]*[^[:space:]]*\.gitignore|(^|[;&|[:space:]])(mv|cp|truncate|ed|ex)[[:space:]].*\.gitignore|git[[:space:]].*(checkout|restore|rm)[[:space:]].*\.gitignore|>>.*\.gitignore.*!|!.*>>[[:space:]]*[^[:space:]]*\.gitignore' <<<"$cmd"; then
  decision="deny"; reason="rewriting .gitignore from the shell (could drop .env rules); use the Edit tool instead"
elif grep -qE "$force_add" <<<"$cmd"; then
  reason="git add --force (adds ignored files)"
elif grep -qE '(^|[;&|[:space:]({`])rm([[:space:]]|$)' <<<"$cmd"; then
  reason="file deletion (rm)"
elif grep -qE '(^|[;&|[:space:]({`])(unlink|shred|rmdir)([[:space:]]|$)|[[:space:]]-delete\b|(^|[;&|[:space:]])truncate[[:space:]]+-s' <<<"$cmd"; then
  reason="file deletion (unlink/shred/rmdir/find -delete/truncate)"
elif grep -qE 'git[[:space:]].*(checkout[[:space:]]+(.*[[:space:]])?--[[:space:]]|restore[[:space:]])' <<<"$cmd"; then
  reason="discarding uncommitted changes (git checkout --/restore)"
elif grep -qiE '\bdrop[[:space:]]+[a-z]|\btruncate[[:space:]]+(table[[:space:]]+)?["`a-z_]|\bdelete[[:space:]]+from\b' <<<"$cmd"; then
  reason="SQL DROP/TRUNCATE/DELETE"
elif grep -qiE '(^|[;&|[:space:]])(dropdb|dropuser)([[:space:]]|$)|\bdrop(Database|Collection|Index(es)?)?[[:space:]]*\(|\bflush(all|db)\b|\bdeleteMany[[:space:]]*\([[:space:]]*\{[[:space:]]*\}' <<<"$cmd"; then
  reason="database drop/flush (dropdb, Mongo drop, Redis FLUSH*)"
elif grep -qiE '\bdb:(drop|reset|schema:load|purge)\b|manage\.py[[:space:]]+(flush|reset_db)\b|prisma[[:space:]]+(migrate[[:space:]]+reset|db[[:space:]]+push.*--force-reset)|alembic[[:space:]]+downgrade\b' <<<"$cmd"; then
  reason="framework database reset (rails/django/prisma/alembic)"
elif grep -qE 'git[[:space:]].*push.*([[:space:]]-[a-zA-Z]*f[a-zA-Z]*\b|--force|[[:space:]]\+[^[:space:]]+|--mirror\b)' <<<"$cmd"; then
  reason="git force push"
elif grep -qE 'git[[:space:]].*push.*([[:space:]]-[a-zA-Z]*d[a-zA-Z]*\b|--delete\b|--prune\b|[[:space:]]:[^[:space:]]+)' <<<"$cmd"; then
  reason="git push deleting remote refs"
elif grep -qE '\bgh[[:space:]]+repo[[:space:]]+sync\b.*--force' <<<"$cmd"; then
  reason="gh repo sync --force (hard reset of target branch)"
elif grep -qE 'git[[:space:]].*(reset[[:space:]]+--hard|clean[[:space:]]+-[a-zA-Z]*f|branch[[:space:]]+-D)' <<<"$cmd"; then
  reason="destructive git operation"
fi

if [ -n "$reason" ]; then
  if [ "$decision" = "deny" ]; then
    msg="Blocked: $reason. .env files must stay ignored by git (project policy)."
  else
    msg="Destructive command detected: $reason. Confirmation required."
  fi
  jq -n --arg r "$msg" --arg d "$decision" \
    '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:$d,permissionDecisionReason:$r}}'
fi
exit 0
