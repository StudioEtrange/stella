# Agent Developer Guide: Adding a New Feature

This guide is intended for developers working on Stella. It provides a step-by-step walkthrough for adding a new feature (e.g., a CLI tool, a library) for the Linux environment.

## Core Concepts

Stella features are defined in "recipe" files located in `@./nix/pool/feature-recipe/`. These are shell scripts that follow a "convention over configuration" pattern. The Stella core engine sources these scripts and calls predefined functions and variables to perform installation, environment setup, and other tasks.

We will use `@./nix/pool/feature-recipe/feature_arkade.sh` as our reference model.

## File Structure Anatomy

A feature recipe file must follow a specific structure. Let's break down the `feature_arkade.sh` example.

### 1. File Naming

The file must be named `feature_<name>.sh`, where `<name>` is the lowercase name of your feature.
- **Example:** `feature_arkade.sh`

### 2. Inclusion Guard

To prevent a script from being sourced multiple times, it must begin and end with an inclusion guard.

```bash
if [ ! "$_ARKADE_INCLUDED_" = "1" ]; then
_ARKADE_INCLUDED_=1

# ... all content ...

fi
```
- **Convention:** `_<NAME_UPPERCASE>_INCLUDED_`

### 3. Main Feature Function: `feature_<name>()`

This function defines the feature's metadata.

```bash
feature_arkade() {
	FEAT_NAME="arkade"
	FEAT_LIST_SCHEMA="0_11_40@x64:binary"
	FEAT_DEFAULT_FLAVOUR="binary"
	FEAT_DESC="arkade provides a portable marketplace..."
	FEAT_LINK="https://github.com/alexellis/arkade"
}
```

- `FEAT_NAME`: The short, lowercase name of the feature.
- `FEAT_LIST_SCHEMA`: A list of available versions, architectures, and installation methods ("flavours").
    - **Format:** `<version>@<arch>:<flavour>`. Multiple entries are separated by spaces.
    - **Example:** `"1_0@x64:binary 2_0@x64:source"`
- `FEAT_DEFAULT_FLAVOUR`: The default flavour to use if not specified by the user (e.g., `binary`, `source`).
- `FEAT_DESC`: A one-line description of the feature.
- `FEAT_LINK`: A space-separated list of relevant URLs.

### 4. Version-Specific Function: `feature_<name>_<version>()`

For each version defined in `FEAT_LIST_SCHEMA`, you must create a corresponding function. The version dots (`.`) are replaced with underscores (`_`) in the function name.

```bash
feature_arkade_0_11_40() {
    FEAT_VERSION="0_11_40"

    # --- Platform-specific variables ---
    if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		if [ "$STELLA_CURRENT_CPU_FAMILY" = "intel" ]; then
			FEAT_BINARY_URL_x64="https://.../arkade"
			FEAT_BINARY_URL_FILENAME_x64="arkade-linux64-${FEAT_VERSION}"
			FEAT_BINARY_URL_PROTOCOL_x64="HTTP"
		fi
		# ... other CPU families like "arm"
	fi
    # ... other platforms like "darwin"

    # --- Generic variables ---
    FEAT_ENV_CALLBACK="feature_arkade_env"
    FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT/arkade"
    FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"
}
```

- `FEAT_VERSION`: The version string, matching the function name.
- **Platform Logic:** Use `if` statements on `$STELLA_CURRENT_PLATFORM` (`linux`, `darwin`) and `$STELLA_CURRENT_CPU_FAMILY` (`intel`, `arm`) to define platform-specific download information.
- `FEAT_BINARY_URL_<arch>`: The URL to download the artifact for a specific architecture (e.g., `x64`, `x86`).
- `FEAT_BINARY_URL_FILENAME_<arch>`: The temporary filename for the downloaded artifact.
- `FEAT_BINARY_URL_PROTOCOL_<arch>`: The download protocol (e.g., `HTTP`, `GIT`).
- `FEAT_INSTALL_TEST`: A check to verify a successful installation. This can be a path to an executable or a command that returns `0` on success. `$FEAT_INSTALL_ROOT` is a Stella variable pointing to the feature's installation directory.
- `FEAT_SEARCH_PATH`: A directory to add to the user's `PATH` environment variable.
- `FEAT_ENV_CALLBACK` (Optional): The name of a function to call for custom environment setup.

### 5. Installation Function: `feature_<name>_install_<flavour>()`

For each flavour defined in `FEAT_LIST_SCHEMA`, you must create an installation function.

```bash
feature_arkade_install_binary() {
	__get_resource "$FEAT_NAME" "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_PROTOCOL" "$FEAT_INSTALL_ROOT" "DEST_ERASE STRIP FORCE_NAME $FEAT_BINARY_URL_FILENAME"
	
	if [ -f "${FEAT_INSTALL_ROOT}/${FEAT_BINARY_URL_FILENAME}" ]; then
		mv "${FEAT_INSTALL_ROOT}/${FEAT_BINARY_URL_FILENAME}" "${FEAT_INSTALL_ROOT}/arkade"
		chmod +x "${FEAT_INSTALL_ROOT}/arkade"
	fi
}
```

- The function name is a combination of `feature_`, `FEAT_NAME`, `_install_`, and the flavour.
- `__get_resource`: This is a core Stella function that handles downloading and extracting resources.
- **Post-install:** After downloading, you typically need to move/rename files and set executable permissions (`chmod +x`).

### 6. Environment Callback (Optional)

If you defined `FEAT_ENV_CALLBACK`, you must implement the corresponding function.

```bash
feature_arkade_env(){
	export PATH="$HOME/.arkade/bin:${PATH}"
	echo "** $HOME/.arkade/bin is added to PATH"
}
```
This function is sourced into the user's environment to set up `PATH` or other variables.

## How to Add a New Linux Feature: A Checklist

1.  **Create File:** Create your new file in `nix/pool/feature-recipe/feature_<myfeature>.sh`.
2.  **Add Guard:** Add the inclusion guard.
3.  **`feature_<myfeature>()`:**
    - [ ] Define `FEAT_NAME`.
    - [ ] Define `FEAT_LIST_SCHEMA` with at least one version, architecture, and flavour (e.g., `binary` for pre-compiled tools).
    - [ ] Define `FEAT_DEFAULT_FLAVOUR`.
    - [ ] Add `FEAT_DESC` and `FEAT_LINK`.
4.  **`feature_<myfeature>_<version>()`:**
    - [ ] Create one function for each version.
    - [ ] Set `FEAT_VERSION`.
    - [ ] Add the `if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]` block.
    - [ ] Inside, define `FEAT_BINARY_URL_<arch>`, `FEAT_BINARY_URL_FILENAME_<arch>`, and `FEAT_BINARY_URL_PROTOCOL_<arch>` for the Linux artifact.
    - [ ] Define `FEAT_INSTALL_TEST` to point to the final executable.
    - [ ] Define `FEAT_SEARCH_PATH` to be the directory containing the executable.
5.  **`feature_<myfeature>_install_<flavour>()`:**
    - [ ] Create the installation function for your flavour (e.g., `feature_<myfeature>_install_binary`).
    - [ ] Call `__get_resource` to download the file.
    - [ ] Add logic to rename the downloaded file to its final name (e.g., `mv <temp_name> <final_name>`).
    - [ ] Make the binary executable (`chmod +x <final_name>`).
6.  **Test:** Use the Stella environment to test your new feature.
    ```bash
    stella install <myfeature>
    ```
