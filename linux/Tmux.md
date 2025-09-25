# Tmux - A Terminal Multiplexer

Tmux allows you to have multiple windows within a single terminal window, and to jump back and forth between them.

A window can be divided into panes, each of which gives you an independent command line.

## Installation

On Ubuntu

```bash
sudo apt-get install tmux
```

On Manjaro

```bash
sudo pacman -Sy tmux
```

## Commands

- To close the window. `CTRL+B`, then hit `x`.

### Sessions

- Starting a new tmux session:

    ```bash
    tmux new -s session1
    ```

`session1` will be displayed as the first entry in the status bar.

- Disconnect from a session, keep it running in bg:

    ```bash
    tmux detach # `attach` for re-attach
    ```

- Attach to session with a specific name:

    ```bash
    tmux attach -t SESSION_NAME
    ```

- List sessions:

    ```bash
    tmux ls
    ```

- Terminate a session:

    ```bash
    tmux kill-session -t SESSION_NAME  # Terminate specific
    tmux kill-session -a               # Kill other than current one
    tmux kill-session -at SESSION_NAME # Kill other than specified one
    tmux kill-server                   # Ending all sessions, windows, panes,...
    ```

- Adding more windows, `CTRL+B`, then hit `c`. Now we have two window in the session.
  - To hop between windows, `CTRL+B` and then following keys:
    - **N**: Display next window
    - **P**: Display prev window
    - **0 to 9**: Display a window numbered 0-9
  - You can choose a window from a list. List appears on `CTRL+B`, then `w`.

- Rename current session, `CTRL+B`, then hit `$`.

### Panes

`CTRL+B` would be prefixed for all the keybindigns.

- Split window horizontally, `"` (double quotes).
- Split window vertically, `%` (percentage sign).
- Flash pane number, `q`.
- Close the current pane, `x`.
- Resize panes via holding `Arrow Navigation keys`.
- Move cursor in panes via `Arrow Navigation keys`.
- Cycle panes in order from current pane, then `o`.
- Swap current pane with the prev/next, `{` / `}`.

| Command/Shortcut     | Action                                      |
|----------------------|---------------------------------------------|
| CTRL+b then %        | Split the current pane vertically.          |
| CTRL+b then "        | Split the current pane horizontally.        |
| CRTL+b then x        | Close the current pane.                     |
| CTRL+b then o        | Switch between panes.                       |
| CTRL+b then z        | Toggle pane zoom (make pane full screen).   |
| CTRL+b then ;        | Toggle between the last two active panes.   |
| CTRL+b then {        | Move the current pane left.                 |
| CTRL+b then }        | Move the current pane right.                |
| CTRL+b then S        | PACE Toggle through different pane layouts. |
| CTRL+b then !        | Convert the current pane into a window.     |
| exit or CTRL+d       | Close the selected pane.                    |
| CTRL+b then q        | Display pane number.                        |
| CTRL+b+[up_arrow]    | Increase pane height.                       |
| CTRL+b+[down_arrow]  | Decrease pane height.                       |
| CTRL+b+[left_arrow]  | Increase pane width.                        |
| CTRL+b+[right_arrow] | Decrease pane width.                        |

### Windows

| Command/Shortcut                      | Action                                         |
|---------------------------------------|------------------------------------------------|
| CTRL+b then c                         | Create a new window.                           |
| CTRL+b then ,                         | Rename the current window.                     |
| CTRL+b then w                         | List all windows.                              |
| CTRL+b then &                         | Kill the current window.                       |
| CTRL+b then n                         | Switch to the next window.                     |
| CTRL+b then p                         | Switch to the previous window.                 |
| CTRL+b then l                         | Open the last window.                          |
| CTRL+b then 0....9                    | Switch to a specific numbered window.          |
| CTRL+b then d                         | Detach from the current session.               |
| tmux select-window -t [window_name]   | Select a specific window by its index or name. |
| tmux rename-window [new_name]         | Rename the current window.                     |

### Copy mode

| Command/Shortcut | Action                                          |
|------------------|-------------------------------------------------|
| CTRL+b then [    | Enter copy mode.                                |
| q                | Exit copy mode.                                 |
| SPACE            | Start text selection in copy mode.              |
| ENTER            | Copy the selected text.                         |
| ESC              | Clear the selected text and exit the copy mode. |
| CTRL+b then ]    | Paste the copied text.                          |
| h                | Move the cursor left.                           |
| j                | Move the cursor down.                           |
| k                | Move the cursor up.                             |
| l                | Move the cursor right.                          |
| w                | Move the cursor one word forward.               |
| b                | Move the cursor one word backward.              |
| CTRL+u           | Scroll up half a page.                          |
| CTRL+d           | Scroll down half a page.                        |
| PgUp             | Scroll up full page.                            |
| PgDn             | Scroll down full page.                          |

## Configuration

Тhe tmux configuration file, `tmux.conf`, allows you to make system-wide or user-specific changes.

To apply changes for all users, create or edit the file in the system directory:

```bash
sudo vim /etc/tmux.conf
```

To apply changes for a single user, create or edit the file in the user’s home directory:

```bash
sudo vim ~/.tmux.conf
```

Once the `tmux.conf` file is created, add custom commands and remap function keys.

The following table contains common configuration examples and their descriptions:

| Command | Description |
|---|---|
| set-option -g prefix C-a \| unbind C-b \| bind C-a send-prefix  |Changes the default CTRL+b binding to CTRL+a to activate functions. |
| unbind % \| bind h split-window –h | Remaps the horizontal split to CTRL+b+h. |
| unbind '"' \| bind v split-window –v | Remaps the vertical split key to CTRL+b+v. |
| set -g status-bg blue \| set -g status-fg black | Changes the color of the status bar (background to blue and foreground to black). You can also use a numerical code (0 – 255) to specify a color. |
| setw -g monitor-activity on \| setw -g visual-activity on | Enables visual notifications for activity in windows. |
| set -g base-index 1 | Starts window numbering at 1 instead of 0. |
| set -g pane-base-index 1 | Starts pane numbering at 1 instead of 0. |

(_Command splitted with **|** are multiline._)

After making changes, save the file and exit the editor. If you have any active tmux sessions, the changes take effect until they are closed and restarted. Detaching and reattaching a session will not apply the new settings.

[gpakosz/.tmux](https://github.com/gpakosz/.tmux)

```bash
curl -fsSL "https://github.com/gpakosz/.tmux/raw/refs/heads/master/install.sh#$(date +%s)" | bash
```
