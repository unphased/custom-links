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

The custom URL handler is built as a macOS Application Bundle.

*   `Info.plist`: Defines the custom URL scheme (e.g., `reveal://`) and other application metadata.
*   `your_actual_script.sh`: A shell script that is bundled with the application. This script contains the custom logic to be executed when the URL is invoked. It receives the full URL as an argument.
*   `build.sh`: A shell script to create the application bundle. It compiles an embedded AppleScript that acts as a lightweight wrapper to receive the URL and execute `your_actual_script.sh`. It also copies the `Info.plist` and the script into the bundle, and registers the application with LaunchServices.

## How to Use

1.  Run the `build.sh` script to create the `.app` bundle and register the URL handler.
    ```bash
    ./build.sh
    ```
2.  Once registered, you can invoke the handler by opening a URL with the custom scheme, for example, from a terminal:
    ```bash
    open reveal://some/data/or/path
    ```
    Or by clicking a link `reveal://some/data/or/path` in an application that supports custom URL schemes.

The `your_actual_script.sh` will then receive `reveal://some/data/or/path` as its first argument and can act upon it.
