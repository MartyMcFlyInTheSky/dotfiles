# dotfiles

My dotfiles repo. Not "production" ready, take everything with a grain of salt.

## Install

Install Git and make sure SSH access to the GitHub repository works. On the new machine, clone the repository as a bare repo, then configure it to use your home directory as its worktree:

```bash
git clone --bare git@github.com:MartyMcFlyInTheSky/dotfiles.git "$HOME/.myconfig"

git --git-dir="$HOME/.myconfig" config core.bare false
git --git-dir="$HOME/.myconfig" config core.worktree "$HOME"
git --git-dir="$HOME/.myconfig" config status.showUntrackedFiles no
git --git-dir="$HOME/.myconfig" config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
git --git-dir="$HOME/.myconfig" fetch origin
git --git-dir="$HOME/.myconfig" branch --set-upstream-to=origin/master master
git --git-dir="$HOME/.myconfig" --work-tree="$HOME" checkout master
```

If checkout reports conflicts with files already in your home directory, back those files up and retry; do not force checkout. After checkout, start a new shell or run `source ~/.bashrc` to load the `conf` alias.

This restores tracked configuration only. Install required applications separately, and transfer private keys and other secrets securely; they are not stored here.
