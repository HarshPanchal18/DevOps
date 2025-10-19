# Useful git setups and configurations

## Setup signed commit for git

### 1. Check if GPG is installed

```bash
gpg --version
```

### 2. List existing GPG keys

```bash
gpg --list-secret-keys --keyid-format LONG
```

### 2. Generate a GPG key

```bash
gpg --full-generate-key
```

- Choose RSA and RSA (default),
- Key size of 4096 bits,
- Validity period if you prefer.
- Enter your name and email address (use the same email address associated with your GitHub account).

### 4. After generating the key, list your keys again to confirm it was created

```bash
gpg --list-secret-keys --keyid-format LONG
```

- Output will look like this:

```bash

/home/user/.gnupg/secring.gpg
------------------------------
sec   4096R/ABC123456789DEF0 2024-01-01 [expires: 2025-01-01]
uid                          Your Name <your.email@example.com>
ssb   4096R/0987654321ABCDEF 2024-01-01
```

- Copy the long string after sec (in this case, ABC123456789DEF0).

### 5. Add the GPG key to your GitHub account

```bash
gpg --armor --export ABC123456789DEF0
```

- This will output your public GPG key in ASCII format.
- Copy the output and go to **`GitHub > Settings > SSH and GPG keys > New GPG key`**. Paste the key there and save it.

### 6. Configure Git to use your GPG key

```bash
git config --global user.signingkey ABC123456789DEF0
```

### 7. Enable commit signing by default

```bash
git config --global commit.gpgsign true
```

### 8. Verify your configuration

```bash
git config --global --list
```

- Ensure you see `user.signingkey` and `commit.gpgsign` in the output.

### 9. Test signing a commit

```bash
git commit -S -m "Test signed commit"
```

- If everything is set up correctly, you should see a message indicating that the commit was signed.

### 10. Verify the signed commit

```bash
git log --show-signature
```

- This will show the commit history along with the signature verification status.
- You should see a line indicating that the commit is signed and the signature is valid.

### 11. Troubleshooting

- If you encounter issues, ensure that your GPG agent is running and that your GPG key is correctly configured.
- You can also check the GPG configuration by running:

```bash
gpg --list-keys
```

- If you need to edit your GPG key, you can use:

```bash
gpg --edit-key ABC123456789DEF0
```

- This allows you to change the user ID, add subkeys, or perform other modifications.

### 12. References

- [GitHub Documentation on GPG](https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key)
- [GPG Documentation](https://www.gnupg.org/documentation/)
- [Git Documentation on Commit Signing](https://git-scm.com/book/en/v2/Git-Tools-Signing-Your-Work)

### 13. Optional: Set up GPG agent for passphrase caching

```bash
echo "use-agent" >> ~/.gnupg/gpg.conf
echo "pinentry-program /usr/bin/pinentry-tty" >> ~/.gnupg/gpg-agent.conf
gpg-connect-agent reloadagent /bye
```

- This allows you to cache your GPG passphrase for a period of time, so you don't have to enter it every time you sign a commit.

### 14. Optional: Configure Git to use GPG for tags

```bash
git config --global tag.gpgSign true
```

- This will ensure that all tags you create are also signed by default.

### 15. Optional: Set up GPG key expiration

```bash
gpg --edit-key ABC123456789DEF0
```

- Use the `expire` command to set an expiration date for your GPG key.
- This is a good security practice to ensure that your key does not remain valid indefinitely.

### 16. Optional: Revoke a GPG key

```bash
gpg --output revoke.asc --gen-revoke ABC123456789DEF0
```

- This will generate a revocation certificate for your GPG key, which you can use to revoke the key if it is compromised or no longer needed.

### 17. Optional: Backup your GPG keys

```bash
gpg --export-secret-keys ABC123456789DEF0 > my-private-key.asc
gpg --export ABC123456789DEF0 > my-public-key.asc
```

- This will create backups of your private and public GPG keys in ASCII format.

### 18. Optional: Use GPG with SSH

```bash
gpg --export-ssh-key ABC123456789DEF0
```

- This will output your GPG key in a format that can be used with SSH, allowing you to use GPG keys for SSH authentication as well.

## Squashing commits

- If you want to write the new commit message from scratch,

    ```bash
    git reset --soft HEAD~3
    git commit
    ```

- If you want to start editing the new commit message with a concatenation of the existing commit messages (i.e. similar to what a pick/squash/squash/…/squash `git rebase -i` instruction list would start you with), then you need to extract those messages and pass them to git commit:

    ```bash
    git reset --soft HEAD~3 &&
    git commit --edit -m"$(git log --format=%B --reverse HEAD..HEAD@{1})" # --reverse appends commit message in sorted order. Remove it for timeline-based sorted.
    ```

- You can use `git merge --squash` for this, which is slightly more elegant than `git rebase -i`. Suppose you're on master and you want to squash the last 3 commits into one.

    > WARNING: First make sure you commit your work—check that git status is clean (since `git reset --hard` will throw away staged and unstaged changes)

    ```bash
    # Reset the current branch to the commit just before the last 3.
    git reset --hard HEAD~3

    # HEAD@{1} is where the branch was just before the previous command.
    # This command sets the state of the index to be as it would just after a merge from that commit
    git merge --squash HEAD@{1}

    # Commit those squashed changes. The commit message will be helpfully prepopulated with the commit messages of all the squashed commits.
    git commit
    ```

- Solution without rebase :

    ```bash
    git reset --soft HEAD~3 # The last 3 commits will be squashed.
    git commit -m "new commit message"
    git push -f
    ```

## Access data from deleted fork repo

1. Fork a repo in your account.
2. Make a commit.
3. Save commit's `SHA` code for future use.
4. Delete forked repo.
5. Now, go on the parent repo from which you have forked.
6. Append `/commit/YOUR-COMMIT-SHA` to the repo's URL.

- You can do the same for Org's repository.

## Access data from deleted repository

1. Create a new private repo in Org.
2. Fork that repo inside Org. Both repos will be private.
3. Add a new file (just make a new commit) into forked.
4. Make parent repo public. The forked repo is still in private visibility.
5. Append forked repo's commit hash to the public repo URL.

## Better at GIT

### `git log` with more visibility

Using `--graph` and `--format` we can quickly get a summary view of git commits in our project.

```bash
git log --graph --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%an%C(reset)%C(bold yellow)%d%C(reset) %C(dim white)- %s%C(reset)' --all
```

## Understanding a particular commit

You’ll often want to understand what’s happening with a specific commit. `git show` can show you a high-level view of changes in a commit, but it also lets you see changes to specific files.

### View the summary of a commit

```bash
git show <commit> --stat
```

Using the --stat flag you’ll see the commit summary along with the files that changed and details on how they changed.

### View specific file changes for a commit

When you want to dive into the specific line changes in a particular file, use `git show` with the file path.

```bash
git show <commit> -- <filepath>
```
