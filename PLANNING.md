# Project Planning: Custom Link URL Handler

This document outlines the current state of the "Custom Link URL Handler" project and details the next steps required to achieve its stated goals, particularly the implementation of the "Reveal" skill.

## Current Project State

As of commit `b24426a` ("feat: Add explicit bash path, error title, and run handler"):

1.  **Core Infrastructure**:
    *   A `build.sh` script compiles an AppleScript application (`MyURLHandler.app`).
    *   The build script bundles `dispatch.sh` and a `handlers/` directory into the app and registers it with LaunchServices.
    *   `Info.plist` is configured to register the `reveal://` URL scheme.
    *   A `dispatch.sh` script acts as a central dispatcher, parsing URLs and delegating to handler scripts.
    *   A `handlers/` directory contains default scripts for actions like `open_in_editor.sh` and `open_in_finder.sh`.
    *   The architecture supports user-specific overrides by placing custom handlers in `~/.config/reveal-handler/handlers`.
    *   `README.md` and `PLANNING.md` are updated to reflect the new architecture.

2.  **Functionality**:
    *   The system can be built and registered.
    *   Invoking a `reveal://` URL triggers `dispatch.sh`.
    *   The dispatcher decodes the path and performs tilde expansion. It then attempts to run handlers in a predefined sequence (e.g., editor, then finder). Each handler is responsible for deciding whether it can process the input, exiting with a non-zero status code to "decline". If one handler declines, the dispatcher falls back to the next in the sequence.
    *   It executes the appropriate handler (`open_in_finder.sh` or `open_in_editor.sh`).
    *   The default `open_in_editor.sh` provides a basic fallback, ready for user-specific logic (e.g., Neovim/VSCode integration).
    *   The system is now flexible and configurable.

## Stated Goals (Recap from README.md)

*   **Primary Goal**: Establish an OS-level IPC layer for integrating actions via text/URLs to trigger advanced capabilities.
*   **Initial Use Case ("Reveal" Skill)**:
    1.  **Input**: A disk location (file or directory path) from the URL.
    2.  **Processing**:
        *   Determine if the location is a source code file.
        *   If source code: Open in a preferred code editor (Neovim/Neovide, or VSCode as an alternative).
        *   If not source code: Reveal in Finder.

## Next Steps

1.  **Implement User-Specific Editor Logic**: **(PENDING)**
    *   **Objective**: Populate the `handlers/open_in_editor.sh` script with the desired Neovim/Neovide/Tmux integration logic.
    *   **Action**: Edit `handlers/open_in_editor.sh` to include the advanced commands for opening files at specific locations in the editor. This will serve as the powerful default for users of the project.

2.  **Refine Configuration**: **(PENDING)**
    *   **Objective**: Make more parts of the system configurable.
    *   **Action**: Consider moving the list of source code extensions from `dispatch.sh` into a configuration file (e.g., `~/.config/reveal-handler/config`) that can be sourced. This would allow users to easily define what they consider a "code file".

3.  **Refine `Info.plist`**: **(PENDING)**
    *   **`CFBundleIdentifier`**: Change `com.example.myurlhandler` to a unique, project-specific identifier (e.g., `com.yourusername.reveal-handler`).
    *   **`CFBundleName`**: Change `MyURLHandler` to a more descriptive name if desired (e.g., "Reveal Handler"). This should match `APP_NAME` in `build.sh`.
    *   **`NSHumanReadableCopyright`**: Update placeholder.

4.  **Testing**: **(PENDING)**
    *   Create a suite of test URLs:
        *   Valid source code file paths.
        *   Valid non-source code file paths.
        *   Valid directory paths.
        *   Paths with spaces or special characters (`~/My Documents/file.txt`).
        *   Invalid paths.
    *   Test editor integrations thoroughly after implementing them.
    *   Test the user override mechanism by creating a custom handler in `~/.config/reveal-handler/handlers`.

5.  **Documentation Updates**: **(PENDING)**
    *   Ensure `README.md` is clear about how to implement custom editor logic in the user's local `open_in_editor.sh` script.

## Longer-Term Considerations

*   **Security**: Sanitize inputs from URLs carefully, especially when constructing shell commands.
*   **Extensibility**: Design `dispatch.sh` or the overall system to easily add more "skills" beyond "Reveal". This might involve a dispatcher based on URL patterns.
*   **AI Integration**: Explore how AI could deduce the "disk location" or other parameters to be passed into the URL, as mentioned in the initial concept.

By tackling these "Next Steps", the "Reveal" skill can be fully implemented, providing a solid foundation for the custom link handler.
