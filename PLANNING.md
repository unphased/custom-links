# Project Planning: Custom Link URL Handler

This document outlines the current state of the "Custom Link URL Handler" project and details the next steps required to achieve its stated goals, particularly the implementation of the "Reveal" skill.

## Current Project State

As of commit `b24426a` ("feat: Add explicit bash path, error title, and run handler"):

1.  **Core Infrastructure**:
    *   A `build.sh` script is in place to compile an AppleScript application (`MyURLHandler.app`).
    *   The build script handles:
        *   Compiling `HandleURL.applescript`.
        *   Copying a custom `Info.plist` into the application bundle.
        *   Bundling a shell script (`your_actual_script.sh`) into the app's Resources.
        *   Registering the application with LaunchServices to handle a custom URL scheme.
    *   `Info.plist` is configured:
        *   Defines `CFBundleIdentifier` (currently `com.example.myurlhandler`).
        *   Defines `CFBundleName` (currently `MyURLHandler`).
        *   Registers the `reveal://` URL scheme.
        *   Includes a descriptive name for the URL type related to opening code locations.
    *   `your_actual_script.sh` is a basic script that currently logs the received URL to `$HOME/custom_url_handler.log`.
    *   `README.md` provides a high-level overview of the project, its concept, the "Reveal" skill use case, and setup instructions.
    *   The `build.sh` script embeds the necessary AppleScript to receive the URL and pass it to `your_actual_script.sh`. This wrapper includes basic error handling and an `on run` handler for direct app launch.

2.  **Missing Components**:
    *   The logic within `reveal.sh` for the "Reveal" skill is not yet implemented.

3.  **Functionality**:
    *   The system can be built and registered.
    *   Invoking a `reveal://` URL will trigger `reveal.sh`, and the URL will be logged.
    *   No actual file/code revealing functionality exists yet.

## Stated Goals (Recap from README.md)

*   **Primary Goal**: Establish an OS-level IPC layer for integrating actions via text/URLs to trigger advanced capabilities.
*   **Initial Use Case ("Reveal" Skill)**:
    1.  **Input**: A disk location (file or directory path) from the URL.
    2.  **Processing**:
        *   Determine if the location is a source code file.
        *   If source code: Open in a preferred code editor (Neovim/Neovide, or VSCode as an alternative).
        *   If not source code: Reveal in Finder.

## Next Steps to Implement the "Reveal" Skill

1.  **AppleScript Wrapper**: **(DONE)**
    *   **Status**: The AppleScript logic has been embedded directly into the `build.sh` script, removing the need for a separate `HandleURL.applescript` file.
    *   **Functionality**: The compiled application correctly captures the incoming URL, finds `reveal.sh` within the app bundle, and executes it, passing the URL as an argument. It includes error dialogs and an `on run` handler for direct launches.

2.  **Enhance `reveal.sh` for "Reveal" Logic**: **(PENDING)**
    *   **URL Parsing**:
        *   Extract the path/data from the received URL (e.g., `reveal://path/to/file` -> `/path/to/file`). Consider how to handle URL encoding.
    *   **Path Validation**:
        *   Check if the extracted path exists.
    *   **Source Code File Detection**:
        *   Implement logic to determine if a file is a "source code file". This could be based on:
            *   File extension (e.g., `.py`, `.js`, `.c`, `.md`).
            *   Shebang line.
            *   A configurable list of extensions or MIME types.
    *   **Editor Integration (Neovim/Neovide)**:
        *   Develop commands to open the file in Neovim or Neovide. This might involve:
            *   Checking if Neovide is running and sending a command.
            *   Using `nvim --remote` or similar IPC mechanisms if a Neovim server is active.
            *   Falling back to opening in a new Neovim instance in the terminal.
    *   **Editor Integration (VSCode)**:
        *   Develop commands to open the file in VSCode (e.g., `code /path/to/file`).
        *   Implement logic for choosing VSCode (e.g., based on a modifier key passed in the URL, or a configuration setting). The `Info.plist` mentions "if holding shift", which implies the AppleScript might need to detect modifier keys, or the URL itself might need to encode this.
    *   **Finder Integration**:
        *   If not a source code file, use `open -R /path/to/file` to reveal in Finder (or `open /path/to/directory` for directories).
    *   **Error Handling**:
        *   Log errors clearly.
        *   Provide user feedback if possible (e.g., via `osascript -e 'display notification "Error message" with title "Custom Link Error"'`).

3.  **Configuration Management**:
    *   **Objective**: Allow users to customize behavior (e.g., preferred editor, list of source code extensions).
    *   **Action**: Consider a configuration file (e.g., `~/.config/custom_link_handler/config.sh` or a JSON/YAML file) that `reveal.sh` can source or parse.

4.  **Refine `Info.plist`**:
    *   **`CFBundleIdentifier`**: Change `com.example.myurlhandler` to a unique, project-specific identifier (e.g., `com.yourusername.customlinkhandler`).
    *   **`CFBundleName`**: Change `MyURLHandler` to a more descriptive name if desired (e.g., "CodeLink Handler"). This should match `APP_NAME` in `build.sh`.
    *   **`NSHumanReadableCopyright`**: Update placeholder.

5.  **Testing**:
    *   Create a suite of test URLs:
        *   Valid source code file paths.
        *   Valid non-source code file paths.
        *   Valid directory paths.
        *   Paths with spaces or special characters.
        *   Invalid paths.
        *   URLs with parameters for editor choice (if implemented).
    *   Test editor integrations thoroughly.

6.  **Documentation Updates**:
    *   Update `README.md` with details on how the "Reveal" skill is implemented, how to configure it, and any new dependencies or setup steps.
    *   Document the expected URL format for the "Reveal" skill.

## Longer-Term Considerations

*   **Security**: Sanitize inputs from URLs carefully, especially when constructing shell commands.
*   **Extensibility**: Design `reveal.sh` or the overall system to easily add more "skills" beyond "Reveal". This might involve a dispatcher based on URL patterns.
*   **AI Integration**: Explore how AI could deduce the "disk location" or other parameters to be passed into the URL, as mentioned in the initial concept.

By tackling these "Next Steps", the "Reveal" skill can be fully implemented, providing a solid foundation for the custom link handler.
