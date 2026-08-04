# Pièges de cette machine

**Modèle à adapter.** Ce fichier décrit la machine sur laquelle les agents travaillent — il
ne vaut pas tel quel ailleurs. Copie-le en `MACHINE.md` dans ton dossier de configuration
Claude Code, puis remplace ce qui suit par ta réalité.

Ce qu'il retient : ce que le journal d'un projet ne peut pas savoir, parce que ça vaut pour
tous les autres. Lu par les agents avant de lever une infrastructure ou de choisir un
critère de vérification. **À enrichir dès qu'un piège se répète d'un projet à l'autre** —
c'est le seul endroit où un tel savoir survit d'un dépôt au suivant.

## Une seule machine, beaucoup de stacks

Quand plusieurs projets actifs partagent une machine et montent chacun leurs conteneurs, les
ports par défaut (5432, 6379, 27017, 3000, 9000) sont **presque toujours déjà pris par un
autre projet**.

**La règle : on ne réquisitionne jamais un port occupé.** On en choisit un libre pour son
propre projet et on le déclare dans son `.env.example`. Arrêter le conteneur d'un voisin
pour libérer un port, c'est casser le travail de quelqu'un sans le savoir.

Constater avant de lancer, plutôt que de supposer :

```bash
docker ps --format '{{.Names}}\t{{.Ports}}'
lsof -nP -iTCP:<port> -sTCP:LISTEN
```

Convention qui marche : décaler d'une centaine le port standard du service et préfixer le
conteneur du nom du projet — `<projet>-mongo` sur 27117, `<projet>-redis` sur 6389. Le nom
du conteneur rend aussi le ciblage possible, ce qui compte pour le point suivant.

> Remplace ce paragraphe par la liste réelle de tes stacks permanentes, si tu en as.

## Jamais de commande destructive à motif large

`pkill -f "nest start"`, `killall node`, `docker rm $(docker ps -aq)`, `docker system prune`
ne distinguent pas un projet d'un autre.

**Ce n'est pas théorique.** Un `pkill -f "nest start"` lancé au service d'un projet a tué le
backend d'un autre, qui tournait au même moment. L'agent l'a signalé de lui-même, mais le
mal était fait — et rien dans le résultat de la commande ne le laissait voir.

Viser un PID identifié, un port vérifié comme sien, un conteneur nommé. Si le ciblage précis
est impossible, demander plutôt que balayer.

## Critères de vérification à ne pas croire sur parole

Avant de retenir une commande comme critère, **la lancer une fois sur la base intacte**.
Beaucoup de projets ont un outillage rouge ou inutilisable dès le départ :

- `next lint` sans configuration ESLint ouvre un **prompt interactif** et sort en 1. Il
  bloque un run non surveillé. Ne pas le déclarer, ne pas s'en servir comme critère.
- Un `lint` rouge depuis des mois — parfois plus de cent erreurs préexistantes — n'est pas
  un critère, c'est du bruit.
- Ne jamais lancer de `lint --fix` global : il réécrit des fichiers hors périmètre.

Un critère qui était déjà rouge avant le travail ne prouve rien sur le travail.

## Aucun appel payant depuis un test

Les projets ont souvent des clés réelles dans leur `.env` — fournisseurs de modèles, envoi
d'e-mails, paiement. Un harnais de test doit **effacer ces variables de son environnement**
et forcer les implémentations de simulation, de sorte qu'une suite lancée par erreur avec un
`.env` de développement ne puisse rien facturer. Le plus sûr est qu'elle s'arrête net si une
clé payante est présente, plutôt que de faire confiance à une variable de bascule.

## Docker tourne, mais rien n'est garanti

Le démon est en général actif, les conteneurs non. Vérifier plutôt que présumer, et relever
soi-même ce dont on a besoin.

## Mobile

> À adapter, ou à supprimer si le sujet ne se pose pas.

Sur une machine équipée de Xcode, `idb` permet le pilotage tactile réel d'une application
dans le simulateur iOS. C'est ce qui permet d'exercer un parcours au doigt plutôt que de le
supposer — et de trouver les bugs qu'aucun test ne voit, comme un formulaire qui perd ses
saisies après un refus. Emplacement des captures : hors du dépôt, ou dans un dossier ignoré
par git.
