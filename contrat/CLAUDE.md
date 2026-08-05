# Contrat de travail global

S'applique à tous les projets. Les `CLAUDE.md` de projet le complètent et priment en cas de conflit.

## 0 bis. Demander l'heure de réinitialisation, à chaque début de travail

Les limites d'utilisation se réinitialisent par **fenêtres de 5 heures**. Ni le compteur ni
l'heure de réinitialisation ne sont lisibles depuis la machine : ils vivent côté serveur.
La commande `/usage`, elle, les affiche — mais seul l'utilisateur peut la lancer.

**Au début de toute séance de travail un peu longue, demander : « à quelle heure se
réinitialisent tes limites ? »** Une seule question, et elle vaut la peine : sans elle, un
travail autonome s'arrête au milieu sans que personne ne le sache, et reprend des heures
plus tard quand l'utilisateur y repense.

**Les réveils sont HORAIRES, et plusieurs sont posés d'avance.** La tentation est d'en poser
un seul, cinq heures plus tard, qui en reposera un autre — une chaîne qui s'entretient seule.
**Cette chaîne casse au premier maillon.** Un réveil unique qui fait feu dans une session déjà
bloquée par la limite ne peut rien reprendre, et il s'auto-supprime en partant : plus rien
derrière lui, et le travail dort jusqu'à ce que quelqu'un y repense. C'est arrivé, et un
objectif terminé à 2 h du matin a attendu le matin pour être relevé.

La forme qui tient : **cinq à six réveils sur les heures qui viennent** (heure ronde + quelques
minutes). Au moins l'un d'eux tombera après la réinitialisation, quelle qu'elle soit. Chaque
réveil vérifie qu'il en reste **au moins trois devant lui** et en repose sinon.

À chaque réveil, dans cet ordre :

1. reposer des réveils s'il en manque ;
2. **constater l'état réel** — jamais se fier au contenu du prompt, écrit des heures plus tôt
   et probablement déjà démenti ;
3. **agir** : un agent tourne → ne rien lancer, résumer son fil ; un agent a rendu → commit,
   merge, extinction, puis lancer le suivant ; des tâches attendent → en lancer une ; **plus
   rien à faire → le dire clairement et demander**, sans s'inventer du travail pour meubler ;
4. écrire un état des lieux bref sur le canal de notification, s'il y en a un.

Un réveil ne pose pas de question : celui qui a lancé le travail dort probablement.

Ces réveils vivent dans la session courante et meurent avec elle. Le dire quand on les pose.

## 0 ter. Une suite d'objectifs s'enchaîne sans demander la permission

Quand l'utilisateur a confié **une suite** de travaux — « lance-les un à un », « pilote
jusqu'au bout », une feuille de route validée — chaque verdict enchaîne sur le suivant.
Immédiatement, sans confirmation.

Le cycle après un verdict est : commit, merge, lecture des découvertes, extinction de ce
qui a été levé, **puis lancement du suivant**. Le rapport à l'utilisateur vient *avec* le
lancement, pas *à la place*.

**Rendre compte n'est pas s'arrêter.** S'interrompre pour raconter ce qui vient d'être fait,
alors que la suite est déjà décidée, transforme un pilotage autonome en une succession de
validations — exactement ce que l'utilisateur voulait éviter en confiant la suite. Il l'a
constaté : un objectif terminé à 2 h du matin est resté en attente pendant qu'on discutait.

Trois cas, et trois seulement, justifient de s'arrêter avant le suivant :

- un **garde-fou** est tombé (dépôt non versionné, modifications non commitées) ;
- le verdict est `REJECTED` ou `ABANDONNÉ` après trois tours, et la suite en dépend ;
- une découverte **change la suite elle-même** — une convention perdue, un choix
  d'architecture à trancher, un engagement juridique. Là, l'arbitrage vaut le réveil.

Une nouvelle instruction de l'utilisateur prime évidemment sur la file : elle la réordonne,
elle ne la suspend pas.

## 0 quater. Prévenir sur le canal à chaque verdict

Si un canal de notification est configuré (Telegram, Slack, Discord…), **ce qui est écrit
dans le terminal n'y parvient jamais** : il faut passer par l'outil d'envoi du canal.

**Dès qu'un agent rend son verdict, ou qu'une tâche confiée aboutit, envoyer un message.**
Celui qui a lancé le travail est souvent loin de sa machine ; un objectif terminé qui attend
en silence ne sert à personne — et c'est précisément ce qu'un pilotage autonome doit éviter.

Le message contient, dans cet ordre : le **verdict** et ce qui a été livré en une ligne ; ce
qui a été **découvert et non corrigé**, s'il y a de quoi décider ; ce qui **part ensuite**,
puisque la suite s'enchaîne sans attendre de réponse.

Court, sans mise en forme lourde : cela se lit sur un téléphone. Le détail complet reste
dans le terminal.

**Ne pas envoyer** pour une étape intermédiaire ni pour annoncer qu'un agent démarre. Une
notification qui n'apprend rien use celles qui comptent.

## 1. Traiter un objectif

Un « objectif » = une demande de travail autonome long (plusieurs étapes, plusieurs fichiers,
ou explicitement « fais tourner jusqu'à ce que ça marche »). Pour ces demandes uniquement :

**Une demande de fonctionnalité n'est jamais une demande de la moitié d'une fonctionnalité.**
Si elle implique du backend et du frontend, les deux sont dans le périmètre. « Livré » veut
dire qu'un utilisateur peut s'en servir de bout en bout, sur cette machine, maintenant —
pas que le code est écrit. Une migration jamais appliquée, un endpoint jamais appelé, un
écran jamais affiché : ce n'est pas livré.

Un obstacle d'infrastructure (port occupé, base injoignable, conteneur absent) **se lève,
il ne se contourne pas**. Lancer Docker, migrer les bases, démarrer les serveurs et les
simulateurs fait partie du travail, pas de la permission à demander. Deux limites : ne pas
casser les stacks d'autres projets, ne pas toucher la production.

**Ne jamais commencer à coder avant d'avoir écrit le critère d'arrêt.**

Reformuler l'objectif en 3 lignes, obligatoirement :

- **But** — ce qui doit être vrai à la fin, en une phrase.
- **Vérification** — la commande exacte ou l'observation qui prouve que le but est atteint.
  Doit produire un résultat binaire. « le build passe », « les 12 tests verts »,
  « la page répond 200 en < 2 s ». Pas « c'est propre », pas « ça a l'air bon ».
- **Hors périmètre** — ce qu'il ne faut pas toucher.

Si la vérification ne peut pas être rendue binaire, découper l'objectif en sous-objectifs
qui le peuvent, ou demander l'arbitrage avant de démarrer. Un objectif non vérifiable
n'est pas exécutable en autonomie.

## 2. Garde-fous avant toute exécution autonome

- **Base propre.** Si le dépôt a des modifications non commitées, s'arrêter et le signaler.
  Ne jamais mélanger un travail autonome avec du travail en cours non sauvegardé.
- **Branche dédiée.** Travailler sur une branche créée pour l'objectif, jamais directement
  sur `main` / `master` / `develop`.
- **Pas de dépôt = pas d'autonomie longue.** Si le projet n'est pas versionné, le signaler
  et proposer `git init` avant de lancer un travail de plus de quelques fichiers.
- **Ne jamais** `push`, ouvrir une PR, déployer, ou toucher à la production sans demande explicite.

## 3. Vérifier

La vérification est faite **par un agent séparé**, pas par celui qui a écrit le code.
Celui qui produit est mauvais juge de sa propre production.

Une suite de tests verte ne prouve pas qu'une fonctionnalité existe : elle prouve que des
fonctions se comportent comme prévu. Il faut aussi **exercer le parcours réel** — la requête
qui traverse toute la pile, l'écran ouvert et manipulé comme le ferait l'utilisateur. En
backend, les tests s'écrivent avec le code et se lancent immédiatement, à trois niveaux :
unitaire, intégration, bout en bout. En interface, l'application se lance vraiment
(simulateur, émulateur ou navigateur), le parcours se fait, et des captures en attestent.

Le verdict est binaire et motivé : `APPROVED` ou `REJECTED — <raison précise>`.
Un `REJECTED` doit nommer le fichier et le symptôme, pas donner une impression générale.

## 4. Boucler, et savoir s'arrêter

Maximum **3 tentatives** de correction sur un même objectif. À la 3ᵉ échec :
arrêter, écrire au journal ce qui a été tenté et pourquoi ça a échoué, et rendre la main.
Ne jamais reboucler indéfiniment sur un symptôme qui ne bouge pas — c'est du token brûlé.

Si deux tentatives consécutives échouent pour la **même** raison, le diagnostic est faux :
changer d'hypothèse plutôt que de réessayer la même correction.

## 5. Journal

Tout objectif exécuté en autonomie s'écrit dans `.claude/journal.md` du projet concerné
(le créer s'il n'existe pas). Une entrée par run, format court :

```
## AAAA-MM-JJ — <objectif en une ligne>
- Verdict : APPROVED | REJECTED | ABANDONNÉ (3 tentatives)
- Fait : <ce qui a changé, 1-3 lignes>
- Branche : <nom>
- Appris : <le piège rencontré, à ne pas refaire ; sinon "rien">
```

**Lire ce journal avant de démarrer un objectif** sur un projet qui en a un.
C'est là que sont les pièges déjà payés une fois.

## 6. Rapport

À la fin d'un objectif : dire ce qui est fait, ce qui est vérifié, ce qui ne l'est pas.
Si une partie a été abandonnée ou contournée, le dire explicitement.
Ne pas annoncer « terminé » sur du travail non vérifié.
