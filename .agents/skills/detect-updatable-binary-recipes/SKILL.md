---
name: detect-updatable-binary-recipes
description:
  Analyzes Linux recipes in the Stella project with flavour `binary` and detects those for which a more recent version is available from the same source currently used.
  This skill identifies update opportunities for bash installation scripts without directly modifying files.
---

# SKILL: detect-updatable-binary-recipes

## DESCRIPTION
Analyzes Linux recipes in the Stella project with flavour `binary` and detects those for which a more recent version is available from the same source currently used.

This skill identifies update opportunities for bash installation scripts without directly modifying files.

---

## USE WHEN
Use this skill when:
- you want to audit Stella recipes to detect updates
- you maintain bash installation scripts in Stella
- you want to compare current versions with upstream available ones
- you are preparing an update of `binary` features

Do not use this skill:
- to modify scripts
- to generate patches
- to analyze anything other than Linux `binary` recipes

---

## INPUTS

| Name | Type | Required | Description |
|------|------|----------|-------------|
| stella_root | string | yes | Root path of the Stella project |
| recipes_scope | string | no | Subset of recipes to analyze (`all` by default) |

---

## OUTPUT

Returns a list of **updatable recipes only**.

Recommended format (Markdown):

| recipe | current_highest_version_in_stella | latest_version_to_add |  url  |
|--------|-----------------------------------|------------------------|------|

If no updates:

`No Linux recipe with flavour binary has a more recent version detected.`


---

## STEPS

### 1. Recipe filtering
- Identify only recipes:
  - Linux
  - with flavour `binary`

---

### 2. Extract current version
- Read Stella recipes
- Identify all declared versions
- Keep the highest version currently present in Stella

---

### 3. Source identification
- Extract the download URL used in the recipe
- Use **exactly this source**
- Do not change site, mirror, or API

---

### 4. Discover available versions
- Inspect the same source URL / repository
- List available versions
- Filter:
  - exclude alpha, beta, rc, nightly, snapshot, draft (unless specified otherwise)
- Keep only actually accessible versions

---

### 5. Version normalization
- Convert versions to Stella format:
  - use `_` as separator
  - example: `1.2.3` → `1_2_3`

---

### 6. Version sorting
- Use Stella logic
- If necessary, use the bash function: `__sort_version` defined in: `stella/nix/common/lib.sh`

---

### 7. Comparison
- Compare:
- current Stella version
- latest available version
- Keep only if: `latest > current`

---

### 8. Build result
For each updatable recipe:

- recipe name
- current version (max in Stella)
- target version (latest available)

---

## RULES

- Always use the **same source as the recipe**
- Never invent a version
- Never extrapolate without proof
- Do not include non-`binary` recipes
- Do not include non-Linux recipes
- Strictly respect Stella version format (`_`)
- Do not include unverifiable versions
- Do not modify scripts

---

## EDGE CASES

### Unusable source
- If the source does not allow version enumeration:
→ ignore the recipe

### Ambiguous version
- If multiple branches exist:
→ stay consistent with the current recipe branch

### Inconsistent format
- If `.` → `_` conversion is ambiguous:
→ report instead of guessing

### Multiple artifacts
- If multiple file types:
→ keep only those used by the recipe

---

## QUALITY CRITERIA

The result must be:
- exact
- verifiable
- reproducible
- faithful to Stella
- without hallucination

---

## PROMPT TEMPLATE

You are working on the Stella project.

Analyze Linux recipes with flavour `binary` and detect those that can be updated.

Constraints:
- Check available versions at the same source URL used by Stella.
- Stella versions use `_` as separator.
- Use Stella logic to sort versions (`__sort_version` if needed).
- Ignore prereleases unless instructed otherwise.
- Do not invent any version.

Output:
List only updatable recipes with:
- name
- current version
- target version
- project URL

Example:
| recipe | current_highest_version_in_stella | latest_version_to_add | url                             |
|--------|-----------------------------------|------------------------|---------------------------------|
| jq     | 1_7                               | 1_8                    | https://github.com/stedolan/jq |
| yq     | 4_44_3                            | 4_45_1                 | https://github.com/mikefarah/yq |


Resources and documentation:
- Full documentation regarding Stella feature recipes is available in `doc/FEATURES.md`


---

## NON-GOALS

This skill must NOT:
- modify recipes
- generate bash code
- propose patches
- change URLs
- handle other flavours than `binary`
- process other OS than Linux

---

## NOTES

- This skill is designed to integrate into a Stella maintenance workflow
- It can be used as a preprocessing step before an automatic update skill
- Full documentation regarding Stella feature recipes is available in `doc/FEATURES.md`