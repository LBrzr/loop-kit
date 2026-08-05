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

## Les serveurs MCP orphelins s'accumulent et brûlent le processeur

Un serveur MCP est lancé par la session Claude Code qui le déclare. **Il ne meurt pas
toujours avec elle.** Chaque `/exit` suivi d'une relance peut en laisser un derrière, et ils
s'empilent en silence.

Constaté : **trois** serveurs du canal Telegram vivants en même temps, dont deux orphelins
de redémarrages successifs, **à 66 % de processeur chacun**. Telegram n'autorise qu'un seul
consommateur de messages par jeton : les autres reçoivent un conflit et retentent, en boucle
serrée. Le verrou `bot.pid` n'enregistre que le dernier démarré — il tue donc un prédécesseur,
jamais deux.

**Le symptôme est trompeur** : le canal fonctionnait, les messages passaient. Rien n'indiquait
que trois processus se battaient pour le même flux. Seul le ventilateur le disait.

À vérifier dès qu'une machine chauffe sans raison, ou après plusieurs redémarrages de session :

```bash
pgrep -f "server\.ts"          # ou le nom du serveur MCP concerné
top -l 2 -o cpu -n 10 -stats pid,cpu,command | tail -11
```

Garder celui dont le PID figure dans le fichier de verrou, tuer les autres **par PID
identifié** — jamais par motif. Ils absorbent `SIGTERM` (gestionnaires d'exception) : il faut
`kill -9`, et viser aussi le parent `bun run` / `node`, qui peut relancer l'enfant.

## Une commande de constat qui n'affiche rien n'a rien constaté

`lsof ... | awk '...' || echo "libre"` **ment**. Le `||` teste le code de sortie du dernier
maillon du tube — `awk`, qui renvoie 0 même sans rien imprimer — et jamais celui de `lsof`.
Résultat : ni « occupé », ni « libre », et un silence qu'on lit comme un feu vert.

Constaté : un port annoncé libre à un agent alors qu'un watcher orphelin le tenait depuis
deux heures. L'agent l'a découvert seul et a dû reprendre l'état à zéro.

**La forme juste** — capturer, puis tester le vide :

```bash
out=$(lsof -nP -iTCP:3010 -iTCP:3011 -sTCP:LISTEN 2>/dev/null)
if [ -z "$out" ]; then echo "libres"; else echo "$out"; fi
```

Vaut pour tout constat d'état : ports, conteneurs, processus. **Un silence n'est pas une
réponse.** Si la commande ne dit pas explicitement « rien », elle n'a rien prouvé — et c'est
exactement ce qui a masqué les serveurs orphelins ci-dessus pendant trente-huit minutes.

## `node --test --test-name-pattern` peut rendre un vert sans rien exécuter

```
node --test --test-name-pattern "<nom>" chemin/du/fichier.test.js
→ tests 1 / pass 1 / fail 0   en 0,67 s
```

**Rien n'a tourné.** Le filtre a écarté le fichier, l'API n'a jamais démarré, la base n'a
jamais été touchée — et la sortie est indiscernable d'un succès réel. Constaté en voulant
rejouer un test isolément pour confirmer une correction.

Le piège est vicieux parce qu'il apparaît exactement quand on cherche à *vérifier vite* : on
isole un test, on le voit vert, on conclut. La durée est le seul indice, et il faut savoir
qu'un test d'intégration ne peut pas rendre en moins d'une seconde.

**La règle :** rejouer le **fichier entier**, sans `--test-name-pattern`, et lire le nombre
de tests exécutés — pas seulement le nombre d'échecs. Un compte de tests anormalement bas
est un vert qui ment.

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
