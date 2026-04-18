---
name: detect-updatable-binary-recipes
description:
  Analyse les recipes Linux du projet Stella ayant une flavour `binary` et détecte celles pour lesquelles une version plus récente est disponible à la même source que celle actuellement utilisée.
  Ce skill permet d’identifier les opportunités de mise à jour des scripts d’installation bash sans modifier directement les fichiers.
---

# SKILL: detect-updatable-binary-recipes

## DESCRIPTION
Analyse les recipes Linux du projet Stella ayant une flavour `binary` et détecte celles pour lesquelles une version plus récente est disponible à la même source que celle actuellement utilisée.

Ce skill permet d’identifier les opportunités de mise à jour des scripts d’installation bash sans modifier directement les fichiers.

---

## USE WHEN
Utiliser ce skill lorsque :
- vous voulez auditer les recipes Stella pour détecter des mises à jour
- vous maintenez des scripts d’installation bash dans Stella
- vous souhaitez comparer les versions actuelles avec celles disponibles en amont
- vous préparez une mise à jour de features `binary`

Ne pas utiliser ce skill :
- pour modifier les scripts
- pour générer des patches
- pour analyser autre chose que les recipes Linux `binary`

---

## INPUTS

| Name | Type | Required | Description |
|------|------|----------|-------------|
| stella_root | string | yes | Chemin racine du projet Stella |
| recipes_scope | string | no | Sous-ensemble de recipes à analyser (`all` par défaut) |


---

## OUTPUT

Retourne une liste des recipes **updatables uniquement**.

Format recommandé (Markdown) :

| recipe | current_highest_version_in_stella | latest_version_to_add |
|--------|-----------------------------------|------------------------|

Si aucune mise à jour :

`Aucune recipe Linux de flavour binary n’a de version plus récente détectée.`



---

## STEPS

### 1. Filtrage des recipes
- Identifier uniquement les recipes :
  - Linux
  - avec flavour `binary`

---

### 2. Extraction de la version actuelle
- Lire les recipes Stella
- Identifier toutes les versions déclarées
- Conserver la version la plus élevée actuellement présente dans Stella

---

### 3. Identification de la source
- Extraire l’URL de téléchargement utilisée dans la recipe
- Utiliser **exactement cette source**
- Ne pas changer de site, miroir ou API

---

### 4. Découverte des versions disponibles
- Inspecter la même URL / repository source
- Lister les versions disponibles
- Filtrer :
  - exclure alpha, beta, rc, nightly, snapshot, draft (sauf option)
- Ne garder que les versions réellement accessibles

---

### 5. Normalisation des versions
- Convertir les versions au format Stella :
  - utiliser `_` comme séparateur
  - exemple : `1.2.3` → `1_2_3`

---

### 6. Tri des versions
- Utiliser la logique Stella
- Si nécessaire, utiliser la fonction bash : `__sort_version` définie dans : `stella/nix/common/lib.sh`


---

### 7. Comparaison
- Comparer :
- version actuelle Stella
- version la plus récente disponible
- Conserver uniquement si : `latest > current`


---

### 8. Construction du résultat
Pour chaque recipe updatable :

- nom de la recipe
- version actuelle (max dans Stella)
- version cible (plus récente disponible)

---

## RULES

- Toujours utiliser la **même source que la recipe**
- Ne jamais inventer de version
- Ne jamais extrapoler sans preuve
- Ne pas inclure de recipes non `binary`
- Ne pas inclure de recipes non Linux
- Respecter strictement le format de version Stella (`_`)
- Ne pas inclure de versions non vérifiables
- Ne pas modifier les scripts

---

## EDGE CASES

### Source non exploitable
- Si la source ne permet pas d’énumérer les versions :
→ ignorer la recipe

### Version ambiguë
- Si plusieurs branches existent :
→ rester cohérent avec la branche actuelle de la recipe

### Format incohérent
- Si conversion `.` → `_` ambiguë :
→ signaler plutôt que deviner

### Artefacts multiples
- Si plusieurs types de fichiers :
→ ne garder que ceux utilisés par la recipe

---

## QUALITY CRITERIA

Le résultat doit être :
- exact
- vérifiable
- reproductible
- fidèle à Stella
- sans hallucination

---

## PROMPT TEMPLATE

Tu travailles sur le projet Stella.

Analyse les recipes Linux dont la flavour est `binary` et détecte celles qui peuvent être mises à jour.

Contraintes :
- Vérifie les versions disponibles à la même URL source que celle utilisée par Stella.
- Les versions Stella utilisent `_` comme séparateur.
- Utilise la logique Stella pour trier les versions (`__sort_version` si nécessaire).
- Ignore les préreleases sauf instruction contraire.
- N’invente aucune version.

Sortie :
Liste uniquement les recipes updatables avec :
- nom
- version actuelle
- version cible
- url du projet

---

## EXAMPLE

| recipe | current_highest_version_in_stella | latest_version_to_add | url                             |
|--------|-----------------------------------|------------------------|---------------------------------|
| jq     | 1_7                               | 1_8                    | https://github.com/stedolan/jq |
| yq     | 4_44_3                            | 4_45_1                 | https://github.com/mikefarah/yq |

---

## NON-GOALS

Ce skill ne doit PAS :
- modifier les recipes
- générer du code bash
- proposer des patches
- changer les URLs
- gérer d’autres flavours que `binary`
- traiter d’autres OS que Linux

---

## NOTES

- Ce skill est conçu pour s’intégrer dans un workflow de maintenance Stella
- Il peut être utilisé en pré-traitement avant un skill de mise à jour automatique