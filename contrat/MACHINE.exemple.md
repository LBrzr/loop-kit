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

## Un gestionnaire de paquets peut réinstaller AVANT chaque script, et sortir en 1

Depuis pnpm 11 (`verify-deps-before-run`), **toute** commande `pnpm run` lance d'abord un
`pnpm install`. Si le projet a des dépendances à script de build non approuvées, cet install
se termine par `[ERR_PNPM_IGNORED_BUILDS]` et **sort en 1** — le script demandé n'est jamais
exécuté, et rien dans le message ne le dit.

Le symptôme apparaît typiquement quand un `package.json` vient d'être modifié : donc en plein
run autonome. Contournement pour une commande, sans toucher à la configuration partagée :

```bash
pnpm --config.verify-deps-before-run=false --filter <paquet> <script>
```

> Vérifie si ton gestionnaire de paquets a un comportement équivalent, et remplace ou
> supprime cette section.

## Construire pendant qu'un serveur de développement tourne casse le serveur

Un `next build` et un `next dev` écrivent dans le **même** dossier de sortie. Construire
pendant que le serveur de dev tourne remplace les fragments sous ses pieds, et il se met à
rendre `Cannot find module './960.js'` sur une page qui marchait une minute plus tôt. Ce n'est
pas une faute applicative, et rien dans le message ne le dit.

Le même piège existe côté serveur (`nest build` réécrivant le dossier qu'un `--watch`
utilise) : le watcher meurt, se relève seul en quelques secondes, et toute requête envoyée
pendant cette fenêtre échoue sans explication.

**La règle : on ne mène pas une construction et un parcours navigateur en parallèle.**

## Le navigateur piloté est PARTAGÉ entre les sessions

Plusieurs agents peuvent piloter le même navigateur en même temps, et **la page sélectionnée
dérive** : on prend une capture sur sa page, et le clic qui suit part sur l'onglet d'un autre
projet. Le risque n'est pas de perdre une action, c'est **d'en exécuter une chez le voisin**.

`select_page` juste avant CHAQUE action, jamais en début de série. Créer sa page dans un
contexte isolé et nommé. **Ne fermer que les pages qu'on a soi-même ouvertes** — les autres
ne sont pas à nous.

Attention aux outils qui n'ont pas d'identifiant de page à valider (exécution de script,
navigation) : ils partent sur la page sélectionnée *au moment de l'appel*, sans rien signaler,
et « réussissent » chez le voisin. Commencer tout script par un garde qui vérifie l'URL et
abandonne sinon.

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

## Le répertoire courant dérive : tout git se fait en `git -C`

Le répertoire courant persiste d'un appel à l'autre, mais **rien ne garantit qu'il soit resté
celui qu'on croit** — un agent voisin, un outil, un `cd` d'une commande composée l'ont
peut-être déplacé depuis. Un `git status` lancé sans le dire répond alors sur le projet d'à
côté.

Le symptôme est le pire possible : un agent en fin de run s'est vu répondre `main` / **0
modification** pour un travail de trente-trois fichiers non commités. Il a annoncé sa
livraison disparue. Elle était intacte — le shell avait dérivé sur un projet voisin, qui était
réellement propre et réellement sur `main`. La sortie était vraie, la question était posée au
mauvais dépôt.

```bash
R=/chemin/absolu/du/projet
git -C "$R" status --porcelain
git -C "$R" log --oneline -1 main
```

Vaut aussi pour `pnpm --dir`, `docker compose -f <chemin>`, et toute commande dont le sens
change selon l'endroit d'où on la lance. **Le pire n'est pas de croire un travail perdu —
c'est de le croire présent ailleurs**, et d'agir sur le dépôt d'un voisin en pensant être
chez soi.

## Une largeur ne se photographie pas, elle se mesure

En émulation mobile, un navigateur **rétrécit la page pour la faire tenir**. Une page dont le
document mesure 439 px dans une fenêtre de 390 rend donc `window.scrollX === 0` : tout semble
aller, et rien ne défile. Constaté sur un écran réellement cassé au doigt.

Le seul critère qui tranche est **`document.documentElement.scrollWidth` comparé à la largeur
visée**. Corollaire pour les captures : une capture prise **tiroir ou menu ouvert** ne prouve
rien — le voile masque exactement ce qu'il fallait regarder.

**Mesurer d'abord, photographier ensuite.** Un chiffre survit à la relecture, une capture non.

## Charger une page dans un état ne prouve pas qu'on l'a vérifiée

Le corollaire de la section précédente, et il se répète à chaque campagne d'interface. Un test
qui charge la page en thème sombre, dans une autre langue, ou sur un gabarit donné, et qui
n'en tire aucun **critère chiffré**, passe au vert quel que soit le rendu. Il prouve que la
page ne plante pas — rien d'autre.

**La question qui tranche : quelle mutation rendrait ce test rouge ?** Si la réponse est « une
erreur JavaScript », le test ne vérifie pas l'état, il vérifie que la page existe. Un contraste
se calcule, une largeur se mesure, la présence d'une chaîne traduite se compare à son fichier
de messages.

**Le piège jumeau : la garde qui ne peut pas se déclencher.** Un sélecteur qui n'existe nulle
part dans l'application rend une garde silencieusement vide, et elle se lit comme un contrôle
passé. Vérifier qu'une garde *sait* échouer coûte une mutation et se paie une fois.

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
