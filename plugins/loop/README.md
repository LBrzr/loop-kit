# loop

Un objectif, un agent, un verdict.

```
/goal-loop sur <projet>, <ce que tu veux obtenir>
```

## La chaîne

```
  toi ──► goal-loop ──► goal-runner ──► implementer ──► (sous-implementers)
                             │                │
                             │                ▼
                             ├──────────► verifier ──► APPROVED
                             │                    └──► REJECTED
                             │                            │
                             └────────────────────────────┘
                                  constate, rédige une
                                  mission neuve, relance
                                     (3 tours maximum)
```

`goal-runner` ne code pas et ne juge pas : il cadre, délègue, arbitre et journalise. Le seul
fichier qu'il écrit est `.claude/journal.md`, dans le projet — ce que la boucle a appris
survit ainsi au contexte qui l'a produit.

Sur un rejet, il ne recopie pas le verdict dans un nouveau prompt : il va lire les fichiers
incriminés, relance la vérification lui-même, distingue ce qui vient du travail de ce qui
était déjà cassé — d'où la baseline mesurée au cadrage — puis rédige une mission neuve qui
dit aussi **ce qui est déjà acquis**, pour que la correction ne défasse pas ce qui marche.

## Les agents séparément

Ils sont réutilisables hors de la boucle. `implementer` prend une unité de travail bornée et
la livre ; `verifier` prend un travail fait et rend un verdict binaire. Tout leur contexte
arrive par le prompt : ni l'un ni l'autre ne suppose quoi que ce soit du projet.

## Deux fichiers hors plugin

`goal-runner` et `implementer` lisent `$CLAUDE_CONFIG_DIR/MACHINE.md` avant d'agir : les
pièges valables sur toute la machine — ports tenus par les projets voisins, commandes
destructives interdites, outils rouges d'origine dont il ne faut pas faire un critère. Son
absence n'est pas une erreur ; c'est à eux de le créer au premier piège rencontré.

Le contrat de travail, lui, vit dans la mémoire utilisateur. Voir `install.sh` à la racine
du dépôt.
