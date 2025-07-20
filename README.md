# Custom Link URL Handler

This project implements a custom URL handler for macOS, providing a foundational Inter-Process Communication (IPC) layer at the operating system level. The primary goal is to facilitate the integration of various actions and trigger advanced capabilities, potentially AI-powered, through simple text-based commands or URLs.

## Concept

The core idea is to establish a flexible mechanism for invoking "skills" or "routines" via custom URLs. This allows different applications or scripts to trigger predefined actions in a standardized way.

## Use Cases

One of the initial use cases envisioned for this system is a "Reveal" skill, designed for intelligent navigation within the filesystem, particularly for code-related locations.

### "Reveal" Skill Example

The "Reveal" skill would work as follows:

1.  **Input**: It receives a disk location (file or directory path) as input, which could be deduced by another process or AI from various sources (e.g., text, voice command).
2.  **Processing**:
    *   It determines if the location points to a source code file.
    *   If it is a source code file, it integrates with a preferred code editor (e.g., Neovim/Neovide, or VSCode if configured) to open the file directly, allowing for immediate editing.
    *   If it is not a source code file (e.g., a document, image, or directory), it reveals the item in Finder.

This approach aims to streamline workflows by providing a seamless way to navigate to and interact with files and directories based on contextual information.

## Implementation Details

The system uses a flexible, handler-based architecture.

*   **URL Handler App**: A minimal macOS Application Bundle (`.app`) whose only job is to register the `reveal://` URL scheme.
*   `dispatch.sh`: The core script inside the app bundle. It acts as a **dispatcher**. When a `reveal://` URL is triggered, this script parses the path and then attempts to execute handlers in a sequence. It first tries to open the path in an editor; if that handler declines (by exiting with a non-zero status code), it falls back to revealing it in the Finder. This allows handlers themselves to contain the logic for what they can open.
*   `handlers/`: A directory of **handler scripts** that perform the actual work. The project includes default handlers for common actions:
    *   `open_in_editor.sh`: Opens source code files. The default version provides a sensible starting point that can be customized.
    *   `open_in_finder.sh`: Reveals files or opens directories in Finder.
*   `build.sh`: A script that assembles the `.app` bundle, copies `dispatch.sh` and the `handlers/` directory into it, and registers the app with macOS.

This architecture allows users to easily customize the behavior without modifying the core project files.

## Configuration

You can override the default behavior by creating your own handler scripts.

1.  Create the configuration directory:
    ```bash
    mkdir -p ~/.config/reveal-handler/handlers
    ```

2.  Copy a default handler to your configuration directory to use it as a template. For example, to customize the editor action:
    ```bash
    cp handlers/open_in_editor.sh ~/.config/reveal-handler/handlers/
    ```

3.  Edit your local script (`~/.config/reveal-handler/handlers/open_in_editor.sh`) to implement your desired logic (e.g., opening files in Sublime Text, or using a specific `nvim` command).

The `dispatch.sh` script will automatically detect and use your local handler instead of the default one bundled with the application. Make sure your custom script is executable (`chmod +x your_script.sh`).

## How to Use

There are two main components to set up:

1.  **The URL Handler Application**: This is the core component that handles `reveal://` URLs.
2.  **The Quick Action**: This is an optional but highly recommended macOS Service that lets you trigger the URL handler from any selected text.

### 1. Build and Register the URL Handler

Run the `build.sh` script to create the `.app` bundle and register it with macOS.

```bash
./build.sh
```

This allows you to invoke the handler by opening a URL with the custom scheme, for example, from a terminal:

```bash
open reveal://some/data/or/path
```

### 2. Install the Quick Action (for easy text selection)

To easily send any selected text (like a file path in a log or document) to the handler, run the `install-quick-action.sh` script.

```bash
./install-quick-action.sh
```

This will install a "Reveal Path" service. To use it:
1.  Highlight a piece of text in any application.
2.  Right-click the selected text.
3.  Navigate to the `Services` menu at the bottom of the context menu.
4.  Click `Reveal Path`.

The `dispatch.sh` script will then receive `reveal://THE_SELECTED_TEXT` as its first argument, parse it, and delegate to the appropriate handler.

#### Manual Installation (if the script fails)

The `install-quick-action.sh` script generates a `.workflow` file. If this script becomes brittle due to macOS updates, you can create the Quick Action manually using Automator:

1.  **Open Automator** and select **File > New**, then choose **Quick Action**.
2.  Configure the workflow to receive **text** input from **any application**.
3.  Add a **Run Shell Script** action to the workflow.
4.  In the action's settings, set **Pass input** to **to stdin** and ensure the shell is set to `/bin/zsh` or your preferred shell.
5.  Paste the following commands into the script area:
    ```bash
    input=$(cat)
    open "reveal://$input"
    ```
6.  Save the Quick Action with a name like "Reveal Path". It will now be available in the Services menu.
