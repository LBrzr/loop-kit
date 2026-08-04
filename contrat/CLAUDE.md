# Contrat de travail global

S'applique à tous les projets. Les `CLAUDE.md` de projet le complètent et priment en cas de conflit.

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
