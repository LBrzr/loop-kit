# loop-kit

Tu donnes un projet et un but. Tu pars. Un verdict t'attend.

Entre les deux, un agent a cadré l'objectif en critère observable, fait écrire le code par
un autre, fait juger le résultat par un troisième qui n'avait pas écrit une ligne, analysé
les rejets, relancé des corrections, et consigné ce qu'il a appris dans le dépôt.

## Le problème que ça résout

Prompter un agent, c'est rester devant l'écran. On relance, on arbitre, on recadre. À
distance, ou pendant qu'on fait autre chose, ça ne tient pas.

Déplacer la boucle dans l'agent change la nature de l'échange : une phrase suffit à lancer
un travail qui peut durer une heure, et la seule chose qui revient est un rapport.

## Ce qu'il y a dedans

| | |
| --- | --- |
| `goal-runner` | **La boucle.** Cadre, délègue, arbitre, journalise. Ne code jamais, ne juge jamais lui-même. |
| `implementer` | **Le producteur.** Lève l'infrastructure, écrit, teste aux trois niveaux, exerce le parcours réel. Se subdivise s'il le juge utile. |
| `verifier` | **Le juge.** Relève la stack de son côté, rejoue tout, casse le code pour éprouver les tests, rend `APPROVED` ou `REJECTED`. |
| `goal-loop` | Le point d'entrée. Ne fait qu'appeler `goal-runner` et relayer son rapport. |

Plus, hors plugin parce que non distribuables : un **contrat** à poser dans ta mémoire
utilisateur, et un **fichier de pièges machine** à adapter (voir `contrat/`).

## Les cinq principes

**Un objectif est vérifiable ou il n'existe pas.** Avant d'écrire une ligne, le but devient
une commande exacte et un parcours à exercer. Sans critère binaire, une boucle ne s'arrête
jamais — elle brûle.

**Celui qui produit ne juge pas.** Le verdict vient d'un agent qui n'a pas écrit le code et
qui a pour consigne de chercher la faille, pas de confirmer. Les affirmations du producteur
sont des hypothèses à tester.

**Livré veut dire utilisable.** Pas « le code est écrit ». Une migration jamais appliquée,
un endpoint jamais appelé, un écran jamais affiché : ce n'est pas livré. Une demande de
fonctionnalité n'est jamais une demande de la moitié d'une fonctionnalité.

**Un obstacle d'infrastructure se lève, il ne se contourne pas.** Docker, les migrations,
les serveurs, les simulateurs : c'est du travail, pas une permission à demander.

**Le savoir-faire vit dans l'agent, jamais dans le prompt.** Un prompt ne porte que ce qui
varie. Recopier de la méthode dedans, c'est le signe qu'elle manque au fichier de l'agent —
et qu'on la repaiera à chaque appel.

## Installer

```bash
/plugin marketplace add <utilisateur>/loop-kit
/plugin install loop@loop-kit
```

Puis le contrat et les pièges machine, que le plugin ne peut pas poser à ta place :

```bash
./install.sh
```

## S'en servir

```
/goal-loop sur <projet>, <ce que tu veux obtenir>
```

Ou en langage courant — la description de `goal-runner` suffit à le déclencher :

> sur mon-api, fais que tous les services aient des tests
> corrige le bug de quota sur les relances jusqu'à ce que ça passe

## Le mode entraînement

Actif, `goal-runner` s'arrête après le cadrage et te montre sa fiche — but, critère de
vérification, baseline mesurée, plan de délégation — avant de dépenser quoi que ce soit.
Tu valides, il enchaîne jusqu'au verdict sans repasser te voir.

```bash
touch  "$CLAUDE_CONFIG_DIR/.goal-loop-training"   # activer
rm     "$CLAUDE_CONFIG_DIR/.goal-loop-training"   # couper
```

Garde-le les premiers runs sur un projet neuf. C'est là qu'un cadrage fautif se rattrape
pour rien, et il se rentabilise vite : sur le premier projet où ce système a tourné, la
fiche de cadrage a révélé que la branche annoncée était la mauvaise et que Docker ne
pouvait pas démarrer — deux erreurs qui auraient été découvertes en plein run, tokens
dépensés.

## Ce que ça ne fait pas

Ça ne commite pas, ne pousse pas, n'ouvre pas de PR : ce n'est pas la décision de l'agent.
Ça ne touche pas à la production. Ça ne casse pas les stacks des projets voisins.

Et ça s'arrête sur deux garde-fous plutôt que d'avancer à l'aveugle : des modifications non
commitées qui traîneraient, ou un projet non versionné. Un travail autonome sans filet n'est
pas un travail autonome, c'est un pari.
