---
name: goal-loop
description: Point d'entrée pour lancer un objectif autonome sur un projet. À utiliser quand l'utilisateur donne un but à atteindre plutôt qu'une tâche précise ("sur X, fais que Y marche", "corrige jusqu'à ce que les tests passent", "lance ça en autonome"), ou invoque /goal-loop. Délègue la totalité du travail à l'agent goal-runner, qui cadre, code, vérifie et corrige seul jusqu'à approbation.
---

# goal-loop

**Tu ne fais qu'une chose : lancer l'agent `goal-runner` et relayer son rapport.**

Tu ne cadres pas l'objectif, tu ne lances pas d'implementer, tu ne juges pas le résultat,
tu n'écris pas le journal. Tout cela vit dans `goal-runner`. Si tu le fais à sa place,
l'utilisateur ne peut plus lâcher un objectif et partir — ce qui est tout l'intérêt.

## Ce qu'il te faut avant de lancer

Deux choses, et deux seulement :

- le **chemin absolu du projet** — si l'utilisateur nomme un projet sans le situer,
  retrouve-le (les projets vivent sous `~/Documents/Dev/Projects/<famille>/<nom>`) ;
- le **but**, dans les mots de l'utilisateur.

S'il manque le but, demande-le. S'il manque le projet et qu'il n'est pas trouvable,
demande-le. Ne demande rien d'autre : `goal-runner` ira chercher le reste lui-même,
y compris la commande de vérification et l'état git.

## Lancer

Un seul appel à l'agent `goal-runner`, avec le chemin absolu et le but. Prompt court :
tout le savoir-faire est dans le fichier de l'agent.

Puis **attends son rapport**. Ne double pas son travail pendant qu'il tourne.

## Relayer

Restitue son rapport tel qu'il l'a rendu — verdict, ce qui est fait, ce qui reste non
vérifié, la branche produite. N'annonce jamais un succès qu'il n'a pas prononcé.

Deux cas demandent une action de ta part :

- son retour commence par `CADRAGE — VALIDATION REQUISE` (mode entraînement actif) :
  présente la fiche à l'utilisateur, et relance `goal-runner` avec le cadrage validé ;
- il s'est arrêté sur un garde-fou (dépôt non versionné, modifications non commitées) :
  présente le blocage et les options, tranche avec l'utilisateur, puis relance-le.

Le mode entraînement se bascule avec `touch` / `rm` sur
`$CLAUDE_CONFIG_DIR/.goal-loop-training`. Le garder actif sur les premiers runs d'un projet
évite de brûler des tokens sur un objectif mal cadré.
