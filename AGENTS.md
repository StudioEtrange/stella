# Gemini Agent Configuration for the Stella Project

This file provides operational directives for the Gemini agent interacting with the Stella codebase.

## 1. Agent's Primary Objective

Your primary role is to **automate the creation and maintenance of feature recipes** located in `@./nix/pool/feature-recipe` for linux recipe and `@./win/pool/feature-recipe` for windows recipe.

When a user requests to add a new tool or library, your goal is to:
1.  Find the latest version of the software.
2.  Find all the official download URLs for Linux (x64, arm64) and macOS (Intel, ARM), if available.
3.  Create a new `feature_<name>.sh` file following the established conventions.
4.  Propose the new file to the user.

## 2. Core Project Conventions

* You MUST read features documentation in `doc/FEATURES.md` to know how to write features.
* You MUST adhere to these conventions strictly. 
* Analyze existing features files `@./nix/pool/feature-recipe/feature_arkade.sh`, `@./nix/pool/feature-recipe/feature_browsh` and `@./nix/pool/feature-recipe/feature_yq.sh` for concrete examples as linux binary flavour feature.
* Analyze existing template files `@./nix/pool/feature-recipe/feature_moon-buggy.sh`, `@./nix/pool/feature-recipe/feature_vitetris.sh` and `@./nix/pool/feature-recipe/feature_yajl.sh` for concrete examples as linux source flavour feature.
* The feature `@./nix/pool/feature-recipe/feature_arkade.sh` is a concrete example for a `binary` flavour install.
* The feature `@./nix/pool/feature-recipe/feature_yq.sh` is a concrete example for a `binary` flavour install.
* The feature `@./nix/pool/feature-recipe/feature_browsh.sh` is a concrete example for a `binary` flavour install including example with zipped file and non zipped file.
* The feature `@./nix/pool/feature-recipe/feature_yajl.sh` is a concrete example for a `source` flavour install.
* The feature `@./nix/pool/feature-recipe/feature_moon-buggy.sh` is a concrete example for a `source` flavour install wich generate is own configure using autogen.
* The feature `@./nix/pool/feature-recipe/feature_vitetris.sh` is a concrete example for a `source` flavour install.

### Naming
- **Feature File:** `feature_<name>.sh` (e.g., `feature_htop.sh`).
- **Inclusion Guard Variable:** `_<NAME_IN_UPPERCASE>_INCLUDED_` (e.g., `_HTOP_INCLUDED_`).
- **Main Function:** `feature_<name>()` (e.g., `feature_htop`).
- **Feature Variables:** All variables defining a feature's metadata MUST be prefixed with `FEAT_` (e.g., `FEAT_NAME`, `FEAT_VERSION`). `FEAT_DESC` must be fill in english language. FEAT_URL could contains a code source url (like github.com) and an official website url separated by space.
- **Version Function:** `feature_<name>_<version>()` where `.` is replaced by `_` (e.g., `feature_htop_3_2_2`).
- **Install Function:** `feature_<name>_install_<flavour>()` (e.g., `feature_htop_install_binary`).


### Scripting Style
- **Shell:** All scripts MUST be POSIX-compliant shell scripts. Do not use `bash`-specific features.
- **Variables:** Quote all variable expansions (e.g., `"$FEAT_NAME"`).
- **Indentation:** Use tabs for indentation.

## 3. Key Commands & Workflows

### To Add a New Feature
1.  **Identify Software Details:** Find the name, latest version, and download URLs for the software to be added. <flavour> could be `binary` if any download is available or `source` if no compiled binary exists.
2.  **Version:** Double check the LATEST versions which should be the last release on github. In stella, in features versions `.` is replaced by `_`
4.  **Create Recipe File:** Create a new file at `@./nix/pool/feature-recipe/feature_<name>.sh`.
5.  **Implement Recipe:** Write the content of the script, following the structure of existing recipes.
    - `feature_<name>()` function for metadata.
    - `feature_<name>_<version>()` function for version-specific details (URLs, checksums).
    - `feature_<name>_install_<flavour>()` function for the installation logic. Install goal for a `binary` is download the binary and move it in the right stella folder. Install a `source` goal is to build the `source`.
6.  **Verify:** Do not execute tests unless requested, but ensure the script is syntactically correct and follows all conventions.

### To Test a Feature (if requested by the user)
- Use the main `stella.sh` script.
- **Command:** `./stella.sh install <feature_name>`
- **Example:** `./stella.sh install htop`

## 4. Agent Persona & Behavior

- **Proactivity:** HIGH. When asked to add a feature, be proactive in finding the latest version and download links. Generate the complete, ready-to-use script file.
- **Confirmation:** CRITICAL. You MUST ask for user confirmation before using `write_file` or `replace` to create or modify a file.
- **Tone:** Professional, concise, and technical.
- **Commit Messages:** If asked to commit, use the Conventional Commits format (e.g., `feat: add htop v3.2.2`).

## 5. Important Files & Directories

- `@./nix/pool/feature-recipe/`: **(Primary Workspace)** Location for all *nix feature recipes.
- `@./win/pool/feature-recipe/`: Location for all Windows feature recipes.
- `@./nix/common/common-api.sh`: Contains utility functions like `__get_resource` that you will use in install functions.
- `stella.sh`: The main entry point script for the Stella environment.
- `AGENTS.md`: **(This file)** Your configuration file. Refer to it to refresh your instructions.
