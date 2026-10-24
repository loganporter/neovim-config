-- Diffview entry points that need git plumbing to work out *what* to diff: the
-- point this branch forked off main, the branch's counterpart on the remote,
-- and -- for checking a rebase -- the same patch series in both places.
--
-- Lazy-required from keymaps.lua, so none of this runs at startup.
local M = {}

--- Run git in `dir`. Returns trimmed stdout, or nil if the command failed.
local function git(dir, ...)
  local out = vim.system({ "git", "-C", dir, ... }, { text = true }):wait()
  if out.code ~= 0 then
    return nil
  end
  return vim.trim(out.stdout or "")
end

--- Where to run git: the current file's directory, falling back to cwd for
--- buffers with no file behind them (terminals, scratch, Diffview panels).
local function repo_dir()
  local dir = vim.fn.expand("%:p:h")
  if vim.fn.isdirectory(dir) == 0 then
    return vim.uv.cwd()
  end
  return dir
end

local function main_branch(dir)
  -- Whatever origin's HEAD points at wins; it's the repo's own answer.
  local head = git(dir, "symbolic-ref", "--quiet", "refs/remotes/origin/HEAD")
  if head and head ~= "" then
    return head:gsub("^refs/remotes/", "")
  end
  for _, ref in ipairs({ "main", "master", "origin/main", "origin/master" }) do
    if git(dir, "rev-parse", "--verify", "--quiet", ref .. "^{commit}") then
      return ref
    end
  end
  return nil
end

--- The branch HEAD tracks. Resolved to a plain ref name rather than left as
--- `@{upstream}`, because the braces would need escaping on the way into
--- `:DiffviewOpen` and are unreadable in a buffer name.
local function upstream(dir)
  local up = git(dir, "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{upstream}")
  if up and up ~= "" then
    return up
  end
  -- Nothing configured to track (a branch pushed with --no-track, or never
  -- pushed at all). A same-named branch on origin is the obvious guess.
  local branch = git(dir, "symbolic-ref", "--quiet", "--short", "HEAD")
  if branch and branch ~= "" then
    local ref = "origin/" .. branch
    if git(dir, "rev-parse", "--verify", "--quiet", ref .. "^{commit}") then
      return ref
    end
  end
  return nil
end

-- The three lookups every entry point below needs, each with the message to
-- show when it comes back empty.

local function need_main(dir)
  local branch = main_branch(dir)
  if not branch then
    vim.notify("No main/master branch found", vim.log.levels.WARN)
  end
  return branch
end

local function need_upstream(dir)
  local up = upstream(dir)
  if not up then
    vim.notify("No upstream branch for HEAD", vim.log.levels.WARN)
  end
  return up
end

local function need_merge_base(dir, a, b)
  local base = git(dir, "merge-base", a, b)
  if not base or base == "" then
    vim.notify(("No common ancestor between %s and %s"):format(a, b), vim.log.levels.WARN)
    return nil
  end
  return base
end

--- This branch's own work: merge base with main -> working tree.
function M.vs_main_base()
  local dir = repo_dir()
  local main = need_main(dir)
  if not main then
    return
  end
  local base = need_merge_base(dir, main, "HEAD")
  if not base then
    return
  end
  vim.cmd("DiffviewOpen " .. base)
end

--- The same view of the *remote* branch: what origin thinks this branch adds
--- on top of main. Committed state only -- there is no working tree over there.
function M.upstream_vs_main_base()
  local dir = repo_dir()
  local main = need_main(dir)
  if not main then
    return
  end
  local up = need_upstream(dir)
  if not up then
    return
  end
  local base = need_merge_base(dir, main, up)
  if not base then
    return
  end
  vim.cmd(("DiffviewOpen %s..%s"):format(base, up))
end

--- Local branch against the branch it tracks: everything a push would carry.
function M.vs_upstream()
  local dir = repo_dir()
  local up = need_upstream(dir)
  if not up then
    return
  end
  vim.cmd("DiffviewOpen " .. up)
end

-- Where a replayed series gets parked. The commits the replay creates live in
-- a throwaway worktree; a ref keeps them reachable once it's gone, and keeps
-- gc off them while the view is open. One fixed name, overwritten each run, so
-- these don't pile up.
local REPLAY_REF = "refs/nvim-gitdiff/replayed"

--- Rebase `rev`'s commits since `old_base` onto `new_base` in a scratch
--- worktree. Returns the ref holding the result, or nil if the replay hit a
--- conflict -- which is its own answer: the rebase being checked resolved
--- something here, so there is no clean series to compare against.
local function replay(dir, rev, old_base, new_base)
  local tree = vim.fn.tempname()
  if not git(dir, "worktree", "add", "--detach", tree, rev) then
    vim.notify("Could not create a temporary worktree", vim.log.levels.ERROR)
    return nil
  end

  local out = vim.system({
    "git", "-C", tree,
    -- Nothing here is a real rebase of a real branch: don't fire the repo's
    -- post-rewrite hooks over it, and don't go asking for a signing key.
    "-c", "core.hooksPath=/dev/null",
    "-c", "commit.gpgsign=false",
    "rebase", "--onto", new_base, old_base,
  }, { text = true }):wait()

  local head = out.code == 0 and git(tree, "rev-parse", "HEAD") or nil
  if head then
    git(dir, "update-ref", REPLAY_REF, head)
  else
    -- Leaves rebase-merge state behind; clear it so the worktree comes out
    -- cleanly below.
    git(tree, "rebase", "--abort")
  end

  git(dir, "worktree", "remove", "--force", tree)
  git(dir, "worktree", "prune")

  if not head then
    -- git's hints here explain how to resolve and continue the rebase, in a
    -- worktree that's just been deleted. Keep the reason, drop the advice.
    local why = {}
    for _, line in ipairs(vim.split(out.stderr or "", "\n", { trimempty = true })) do
      -- Progress ("Rebasing (1/2)") is written over itself with CRs; the last
      -- segment of the line is the part that survived on screen.
      line = vim.trim(line:gsub(".*\r", ""))
      if line ~= "" and not line:match("^hint:") and not line:match("^Rebasing %(") then
        table.insert(why, line)
      end
    end
    vim.notify(
      ("Replaying %s onto HEAD's base hit a conflict; `git range-diff %s...HEAD` still works.\n%s")
        :format(rev, rev, table.concat(why, "\n")),
      vim.log.levels.ERROR
    )
    return nil
  end
  return REPLAY_REF
end

--- The rebase check, in the Diffview UI. Diffview can only ever show a diff
--- between two trees, and after a rebase the two branch tips don't share a
--- base -- so diffing them drags in every commit the rebase picked up from
--- main. Replaying origin's series onto the base HEAD now sits on fixes that:
--- both sides start from the same commit, main's new commits cancel out, and
--- what's left is exactly what the rebase did to *your* work -- conflict
--- resolutions, amendments, hunks that went missing. A clean rebase diffs to
--- nothing.
---
--- Cumulative, not per commit: this says what changed, not which commit
--- changed it. `git range-diff` is the per-commit answer when that matters,
--- and the fallback when the replay itself conflicts.
function M.rebase_replay()
  local dir = repo_dir()
  local main = need_main(dir)
  if not main then
    return
  end
  local up = need_upstream(dir)
  if not up then
    return
  end

  local old_base = need_merge_base(dir, main, up)
  if not old_base then
    return
  end
  local new_base = need_merge_base(dir, main, "HEAD")
  if not new_base then
    return
  end

  -- Not rebased since the push: the two series already fork from the same
  -- commit, so their tips can be diffed as they stand. No replay needed.
  local rev = up
  if old_base ~= new_base then
    vim.notify(("Replaying %s onto HEAD's base..."):format(up), vim.log.levels.INFO)
    vim.cmd("redraw")
    rev = replay(dir, up, old_base, new_base)
    if not rev then
      return
    end
  end

  -- Committed state on both sides, so uncommitted work doesn't read as a
  -- change the rebase made.
  local diff = vim.system({ "git", "-C", dir, "diff", "--quiet", rev, "HEAD" }, { text = true }):wait()
  if diff.code == 0 then
    -- Say it outright: an empty Diffview panel is a worse way to report that
    -- the rebase changed nothing.
    vim.notify(("Clean: %s replayed onto HEAD's base is identical to HEAD"):format(up), vim.log.levels.INFO)
    return
  end

  vim.cmd(("DiffviewOpen %s..HEAD"):format(rev))
end

return M
