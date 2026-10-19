# Git Branching Strategy

## Overview

This document outlines our team's branching strategy for the MyAliv Mobile App project. Following these guidelines ensures clean code management and smooth collaboration.

## Branch Structure

```
main (production-ready code)
└── develop (main development branch)
    ├── john/MA-123-login-feature
    ├── sarah/MA-456-payment-ui
    └── mike/MA-789-bug-fix-crash
```

## Main Branches

### `main`
- **Purpose**: Production-ready code
- **Protection**: Protected branch (requires PR approval)
- **Deployment**: Automatically deployed to production
- **Direct commits**: ❌ Not allowed

### `develop`
- **Purpose**: Integration branch for all development work
- **Protection**: Protected branch (requires PR approval)
- **Merges from**: Feature/bugfix branches
- **Merges to**: `main` (for releases)
- **Direct commits**: ❌ Not allowed

## Working Branches

### Naming Convention

All working branches must follow this format:

```
<devName>/<ticketName>
```

**Components:**
- `devName`: Developer's first name (lowercase)
- `ticketName`: Descriptive ticket/task name (kebab-case)

**Examples:**
- `john/MA-123-login-feature`
- `sarah/MA-456-payment-ui-redesign`
- `mike/MA-789-fix-crash-on-startup`
- `lisa/MA-234-add-dark-mode`
- `alex/MA-567-update-dependencies`

### Branch Types

**Feature branches:** For new features
```
john/MA-123-user-authentication
sarah/MA-456-payment-gateway-integration
```

**Bugfix branches:** For bug fixes
```
mike/MA-789-fix-login-crash
lisa/MA-234-fix-payment-validation
```

**Hotfix branches:** For urgent production fixes
```
alex/HOTFIX-567-critical-security-patch
```

## Workflow

### 1. Starting New Work

```bash
# Make sure you're on develop and it's up to date
git checkout develop
git pull origin develop

# Create your working branch
git checkout -b <yourName>/<ticketName>

# Example:
git checkout -b john/MA-123-login-feature
```

### 2. Daily Development

```bash
# Make changes to your code
# Stage and commit regularly with meaningful messages
git add .
git commit -m "feat: add login form validation"

# Push your branch to remote (first time)
git push -u origin john/MA-123-login-feature

# Push subsequent changes
git push
```

### 3. Keeping Your Branch Updated

```bash
# Fetch latest changes from develop
git checkout develop
git pull origin develop

# Switch back to your branch
git checkout john/MA-123-login-feature

# Merge develop into your branch
git merge develop

# Or rebase (if you prefer linear history)
git rebase develop

# Push the updated branch
git push
```

### 4. Creating a Pull Request

When your work is ready for review:

1. **Push your latest changes:**
   ```bash
   git push
   ```

2. **Create PR on GitHub/GitLab:**
   - Base branch: `develop`
   - Compare branch: `<yourName>/<ticketName>`
   - Title: `[MA-123] Add login feature`
   - Description: Provide context, testing notes, screenshots

3. **Request reviews** from team members

4. **Address feedback** by pushing new commits to your branch

5. **Squash and merge** once approved

### 5. After PR is Merged

```bash
# Switch to develop
git checkout develop

# Pull latest changes (includes your merged PR)
git pull origin develop

# Delete your local branch (optional but recommended)
git branch -d john/MA-123-login-feature

# Delete remote branch (if not auto-deleted)
git push origin --delete john/MA-123-login-feature
```

## Commit Message Guidelines

Follow the conventional commits format:

```
<type>: <description>

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, semicolons, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```bash
git commit -m "feat: add login button to home screen"
git commit -m "fix: resolve crash on payment screen"
git commit -m "refactor: simplify authentication logic"
git commit -m "docs: update README with setup instructions"
```

## Best Practices

### ✅ DO

- **Create a new branch** for each ticket/task
- **Keep branches focused** on a single feature or fix
- **Commit frequently** with meaningful messages
- **Pull from develop regularly** to stay updated
- **Test your code** before creating a PR
- **Keep PRs small** (easier to review)
- **Delete branches** after merging
- **Resolve conflicts promptly**

### ❌ DON'T

- **Don't commit directly** to `develop` or `main`
- **Don't work on multiple tickets** in the same branch
- **Don't push untested code**
- **Don't force push** to shared branches (unless necessary and communicated)
- **Don't leave branches stale** for too long
- **Don't merge without approval**

## Common Scenarios

### Scenario 1: You Need to Switch Tasks Mid-Work

```bash
# Save your current work
git add .
git commit -m "wip: partial implementation of login feature"
git push

# Or use git stash if you don't want to commit yet
git stash

# Switch to develop and create new branch
git checkout develop
git pull
git checkout -b john/MA-999-urgent-fix

# Later, come back to your original work
git checkout john/MA-123-login-feature

# If you used stash:
git stash pop
```

### Scenario 2: Merge Conflict

```bash
# Update your branch from develop
git checkout develop
git pull
git checkout john/MA-123-login-feature
git merge develop

# Conflicts appear - resolve them in your editor
# After resolving, mark as resolved:
git add .
git commit -m "chore: resolve merge conflicts with develop"
git push
```

### Scenario 3: Need to Update Your PR

```bash
# Make changes based on review feedback
git add .
git commit -m "refactor: address code review comments"
git push

# The PR will automatically update
```

### Scenario 4: Hotfix for Production

```bash
# Create branch from main (not develop)
git checkout main
git pull origin main
git checkout -b alex/HOTFIX-567-critical-fix

# Make the fix
git add .
git commit -m "fix: resolve critical security vulnerability"
git push -u origin alex/HOTFIX-567-critical-fix

# Create PR to main (and separately to develop)
```

## Visual Workflow

```
1. Create branch from develop
   develop ─┐
            └─> yourName/ticket

2. Work on your branch
   yourName/ticket ─> commit ─> commit ─> commit

3. Keep updated with develop
   develop ────────────────┐
                           ├─> yourName/ticket
   yourName/ticket ────────┘

4. Create PR and merge back to develop
   yourName/ticket ─────┐
                        ├─> develop
   develop ─────────────┘

5. Delete your branch
   yourName/ticket [deleted]
```

## Quick Reference

| Action | Command |
|--------|---------|
| Update develop | `git checkout develop && git pull` |
| Create new branch | `git checkout -b yourName/ticket-name` |
| Stage changes | `git add .` or `git add <file>` |
| Commit | `git commit -m "type: message"` |
| Push first time | `git push -u origin yourName/ticket-name` |
| Push after first time | `git push` |
| Merge develop into branch | `git merge develop` |
| View branches | `git branch -a` |
| Delete local branch | `git branch -d yourName/ticket-name` |
| Delete remote branch | `git push origin --delete yourName/ticket-name` |

## Getting Help

If you run into issues:

1. **Don't panic** - most Git issues are reversible
2. **Ask the team** in the dev channel
3. **Check Git documentation**: `git help <command>`
4. **Common rescue command**: `git reflog` (to find lost commits)

## Questions?

Contact the tech lead or ask in the development team channel.

---

**Last Updated**: 2026-04-03
**Version**: 1.0.0
