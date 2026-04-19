# Agent informations and instructions for the Stella Framework Project

This file provides operational directives for AI agents interacting with the Stella framework codebase.

This file concern only Stella framework and its files from this folder and its subfolder.

## Core Project Conventions

* You MUST strictly adhere to all provided conventions from every files and below.

### Code Scripting Style conventions
- **Shell:** All scripts MUST be compatible with bash 3.2 to be used on linux and MacOs.
- **Variables:** Quote all variable expansions (e.g., `"$FEAT_NAME"`).
- **Indentation:** Use tabs for indentation.

## Agent Persona & Behavior

- **Proactivity:** HIGH.
- **Confirmation:** CRITICAL. You MUST ask for user confirmation before using `write_file` or `replace` to create or modify a file.
- **Tone:** Professional, concise, and technical.
- **Commit Messages:** If asked to commit, use the Conventional Commits format (e.g., `feat: add htop v3.2.2`).

## Stella Documentation

* You MUST read features documentation in `doc/FEATURES.md` to know about features concept.

## Additional agent ressources and skills

* Additional specific SKILL for stella project MUST beloaded from `.agents/skills`

## Important Files & Directories

- `@./nix/pool/feature-recipe/`: **(Primary Workspace)** Location for all *nix feature recipes.
- `@./win/pool/feature-recipe/`: Location for all Windows feature recipes.
- `@./nix/common/common-api.sh`: Contains utility functions like `__get_resource` that you will use in install functions.
- `stella.sh`: The main entry point script for the Stella environment.
- `AGENTS.md`: **(This file)** Your configuration file. Refer to it to refresh your instructions.
