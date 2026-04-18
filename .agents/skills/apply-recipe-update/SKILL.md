---
name: apply-recipe-update
description:
  Modifie à jour les recipes Linux du projet Stella ( de type flavour `binary`) en ajoutant une version cible donnée, en modifiant proprement les scripts bash existants.
  Ce skill prend en entrée une liste de recipes à mettre à jour (typiquement issue de `detect-updatable-binary-recipes`) et génère les modifications nécessaires pour ajouter la version cible à la recipe en respectant strictement les conventions de format et de style du projet.
---

# SKILL: apply-recipe-update

## DESCRIPTION
Modifie à jour les recipes Linux du projet Stella ( de type flavour `binary`) en ajoutant une version cible donnée, en modifiant proprement les scripts bash existants.

Ce skill prend en entrée une liste de recipes à mettre à jour (typiquement issue de `detect-updatable-binary-recipes`) et génère les modifications nécessaires pour ajouter la version cible à la recipe en respectant strictement les conventions de format et de style du projet.

---

## USE WHEN
Utiliser ce skill lorsque :
- vous avez identifié des recipes updatables
- vous souhaitez générer automatiquement les modifications bash
- vous voulez produire un patch prêt à review

Ne pas utiliser ce skill :
- sans version cible validée
- pour autre chose que les recipes Linux `binary`
- pour deviner des URLs ou des versions

---

## INPUTS

| Name | Type | Required | Description |
|------|------|----------|-------------|
| stella_root | string | yes | Chemin racine du projet Stella |
| updates | array | yes | Liste des recipes pour lequelles il faut ajouter une version plus recente à la cible |
| dry_run | boolean | no | Si `true`, ne modifie rien, produit uniquement le patch (default: true) |

### Format de `updates`

```
| recipe | current_highest_version_in_stella | latest_version_to_add | url                             |
|--------|-----------------------------------|------------------------|---------------------------------|
| jq     | 1_7                               | 1_8                    | https://github.com/stedolan/jq |
| yq     | 4_44_3                            | 4_45_1                 | https://github.com/mikefarah/yq |
```

---

## OUTPUT

### Mode dry_run (default)
- Le meme tableau que l’input `updates` avec une colonne supplémentaire `status` indiquant le résultat de la tentative de mise à jour (`ready`, `error`, `skipped`)
- Un patch unifié (diff) montrant les changements qui seraient appliqués


### Mode apply
- Le meme tableau que l’input `updates` avec une colonne supplémentaire `status` indiquant le résultat de la tentative de mise à jour (`ready`, `error`, `skipped`)
- Les fichiers de recipes modifiés avec les changements appliqués

---

## STEPS

### 1. Validation des entrées
- Vérifier que chaque recipe existe
- Vérifier que la version cible est cohérente (format Stella `_`)
- Vérifier que `target_version > current_version`

---

### 2. Localisation de la recipe
- Trouver le fichier bash correspondant à la recipe
- Identifier :
  - bloc de version
  - URL de téléchargement
  - variables associées

---

### 3. Ajoute la version
- Ajouter la version cible à la recipe
- Respecter strictement le format Stella (`_`)
- Bien positionner la nouvelle version dans la liste des versions (ordre décroissant)
- Vérifier l’URL de la nouvelle version
- Ne pas toucher aux autres versions.
  
---

### 4. Normalisation des versions
- Convertir les versions au format Stella :
  - utiliser `_` comme séparateur
  - exemple : `1.2.3` → `1_2_3`

---

### 5. Tri des versions
- Utiliser la logique Stella
- Si nécessaire, utiliser la fonction bash : `__sort_version` définie dans : `stella/nix/common/lib.sh`


---
### 6. Ajout de la fonction feature_<version> correspondant à la nouvelle version
- Si la recipe utilise une fonction bloc `feature_<version>`, ajouter une nouvelle fonction pour la version cible
- Copier la logique de la fonction existante (ex: `feature_1_7`) en adaptant la version et les URLs
- Ne pas ajouter de logique supplémentaire, se contenter de dupliquer et adapter la fonction existante
- Modifier les références à la version dans la nouvelle fonction (ex: `JQ_VERSION="1_8"`)


---
### 7. Vérification des artefacts
- Vérifier que l’URL cible existe réellement
- Vérifier la cohérence nom/version

---

### 8. Respect des conventions Stella
- Ne pas casser :
  - structure du script
  - fonctions existantes
  - style bash
- Conserver :
  - indentation
  - nommage
  - logique existante

---

### 9. Génération du patch
- Produire un diff unifié (`git diff` style)
- Inclure uniquement les changements nécessaires
- Aucun bruit inutile

---

## RULES

- Ne jamais inventer une URL
- Ne jamais changer de source
- Ne jamais modifier autre chose que la version et ses impacts directs
- Ne pas refactorer le script
- Ne pas ajouter de logique
- Respect strict du format Stella
- Ne modifier que les recipes demandées

---

## EDGE CASES

### Version non trouvée
→ Ne pas modifier la recipe, signaler erreur

### URL cassée après update
→ Ne pas appliquer, remonter erreur

### Pattern d’URL complexe
→ Adapter uniquement la partie version

### Plusieurs occurrences de version
→ Mettre à jour toutes les occurrences pertinentes

### Version dans plusieurs variables
→ Synchroniser toutes les variables

---

## QUALITY CRITERIA

Le patch doit être :
- minimal
- exact
- reproductible
- lisible
- conforme aux conventions Stella

---

## PROMPT TEMPLATE

Tu travailles sur le projet Stella.

Ta mission est d'ajouter des versions cibles dans des recipes Linux de flavour `binary`.

Contraintes :
- Ne modifie que les recipes fournies
- Respecte le format de version Stella (`_`)
- Mets à jour uniquement ce qui est nécessaire
- Conserve la structure bash existante
- Ne change pas la source des URLs
- Vérifie que les artefacts existent
- Ne fais aucune hypothèse non vérifiable

Produit :
- un patch propre (diff)
- ou applique les changements si demandé

---


## EXAMPLE OUTPUT (dry_run)

```diff
- JQ_VERSION="1_7"
+ JQ_VERSION="1_8"

- https://.../jq-1.7.tar.gz
+ https://.../jq-1.8.tar.gz
```

---

## NON-GOALS

Ce skill ne doit PAS :
- détecter les updates (c’est le rôle du skill précédent)
- modifier d’autres recipes
- changer l’architecture du script
- ajouter des features
- corriger du code existant
- ne doit modifier aucun fichier si `dry_run` est `true`

---

## NOTES

- Ce skill est conçu pour fonctionner après :
  → `detect-updatable-binary-recipes`
- Peut être intégré dans un pipeline automatisé :
  detect → apply → test → commit
