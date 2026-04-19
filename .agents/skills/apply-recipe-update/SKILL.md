---
name: apply-recipe-update
description:
  Updates Linux recipes in the Stella project (of flavour type `binary`) by adding a given target version, properly modifying existing bash scripts.
  This skill takes as input a list of recipes to update (typically produced by `detect-updatable-binary-recipes`) and generates the necessary modifications to add the target version to the recipe while strictly respecting the project's formatting and style conventions. And print a result table indicating the status of each update attempt.
---

# SKILL: apply-recipe-update

## DESCRIPTION
Updates Linux recipes in the Stella project (of flavour type `binary`) by adding a given target version, properly modifying existing bash scripts.

This skill takes as input a list of recipes to update (typically produced by `detect-updatable-binary-recipes`) and generates the necessary modifications to add the target version to the recipe while strictly respecting the project's formatting and style conventions. And print a result table indicating the status of each update attempt.

---

## USE WHEN
Use this skill when:
- you have identified updatable recipes
- you want to automatically generate bash modifications
- you want to produce a patch ready for review

Do not use this skill:
- without a validated target version
- for anything other than Linux `binary` recipes
- to guess URLs or versions

---

## INPUTS

| Name | Type | Required | Description |
|------|------|----------|-------------|
| stella_root | string | yes | Root path of the Stella project |
| updates | array | yes | List of recipes for which a more recent target version must be added |
| dry_run | boolean | no | If `true`, does not modify anything, only produces the patch (default: true) |

### `updates` input format

```
| recipe | current_highest_version_in_stella | latest_version_to_add | url                             |
|--------|-----------------------------------|------------------------|---------------------------------|
| jq     | 1_7                               | 1_8                    | https://github.com/stedolan/jq |
| yq     | 4_44_3                            | 4_45_1                 | https://github.com/mikefarah/yq |
```
---

## OUTPUT

- You MUST ALWAYS print a result table, that indicate for each recipe whether the update was successfully applied or if an error occurred (with error details), each time this skill is executed, regardless of the `dry_run` mode.
- The result table format is the same as the `updates` input with an additional `status` column indicating the result (`OK`, `KO`) of the update attempt and the reason of a KO result
- Result table must be in Markdown format

  Output result table example:
  | recipe | current_highest_version_in_stella | latest_version_to_add | url                             | status           |
  |--------|-----------------------------------|------------------------|---------------------------------|------------------|
  | jq     | 1_7                               | 1_8                    | https://github.com/stedolan/jq | OK                 |
  | yq     | 4_44_3                            | 4_45_1                 | https://github.com/mikefarah/yq | KO : URL not accessible |

- if `dry_run` is `false` output the modified recipe files with the changes applied

- if `dry_run` is `true` do NOT modify any file.
- if `dry_run` is `true` (default), also produce a unified patch (diff) showing the changes that would be applied to the recipe files to add the target versions. The patch should be clean and ready for review.
  
  Unified patch example:

  ```diff
  - JQ_VERSION="1_7"
  + JQ_VERSION="1_8"

  - https://.../jq-1.7.tar.gz
  + https://.../jq-1.8.tar.gz

  ```

---

## STEPS

### 1. Input validation
- Verify that each recipe exists
- Verify that the target version is consistent (Stella `_` format)
- Verify that `target_version > current_version`

---

### 2. Locate the recipe
- Find the bash file corresponding to the recipe
- Identify:
  - version block
  - download URL
  - associated variables

---

### 3. Add the version
- Add the target version to the recipe
- Strictly respect the Stella format (`_`)
- Add the new version in the version list (descending order)
- Verify the URL of the new version
- Do not modify other versions.
  
---

### 4. Version normalization
- Convert versions to Stella format:
  - use `_` as separator
  - example: `1.2.3` → `1_2_3`

---

### 5. Version sorting
- Use Stella logic
- If necessary, use the bash function: `__sort_version` defined in: `stella/nix/common/lib.sh`

---

### 6. Add the feature_<version> function corresponding to the new version
- If the recipe uses a `feature_<version>` function block, add a new function for the target version
- Copy the logic from the existing function (e.g., `feature_1_7`), add it just BEFORE the copied functions and adapt version and URLs
- Do not add additional logic, only duplicate and adapt the existing function
- Update version references in the new function (e.g., `JQ_VERSION="1_8"`)

---

### 7. Artifact verification
- Verify that the target URL actually exists
- Verify name/version consistency
- Verifiy that the artifact URL is accessible and not broken (e.g., by checking HTTP status code or using `curl --head`)
- If the URL is not accessible, do not apply the update and report an error in the output table, in the status field (e.g., `KO: URL not accessible`)

---

### 8. Respect Stella conventions
- Do not break:
  - script structure
  - existing functions
  - bash style
- Preserve:
  - indentation
  - naming
  - existing logic

---

### 9. Patch generation
- Produce a unified diff (`git diff` style)
- Include only necessary changes
- No unnecessary noise

---

## RULES

- Never invent a URL
- Never change the source
- Never modify anything other than the version and its direct impacts
- Do not refactor the script
- Do not add logic
- Strictly respect Stella format
- Only modify the requested recipes

---

## EDGE CASES

### Version not found
→ Do not modify the recipe, report error

### Broken URL after update
→ Do not apply, report error

### Complex URL pattern
→ Adapt only the version part

### Multiple version occurrences
→ Update all relevant occurrences

### Version in multiple variables
→ Synchronize all variables

---

## QUALITY CRITERIA

The patch must be:
- minimal
- exact
- reproducible
- readable
- compliant with Stella conventions

---

## PROMPT TEMPLATE

You are working on the Stella project.

Your mission is to add target versions to Linux recipes of flavour type `binary`.

Constraints:
- Only modify the provided recipes
- Respect the Stella version format (`_`)
- Update only what is necessary
- Preserve the existing bash structure
- Do not change URL sources
- Verify that artifacts exist
- Do not make any unverifiable assumptions

Produce:
- a clean patch (diff) ready for review if in dry_run mode
- or apply the changes if requested
- a status report for each recipe indicating success or error

Resources and documentation:
- Full documentation regarding Stella feature recipes is available in `doc/FEATURES.md`

---



## NON-GOALS
This skill must NOT:
- detect updates (this is the role of the previous skill)
- modify other recipes
- change the script architecture
- add features
- fix existing code
- modify any file if dry_run is true

---

## NOTES

- This skill is designed to work after detecting updatable recipes using `detect-updatable-binary-recipes` skill
- Can be integrated into an automated pipeline for maintaining Stella recipes.
- The complete documentation regarding Stella feature recipes is available in `doc/FEATURES.md`

