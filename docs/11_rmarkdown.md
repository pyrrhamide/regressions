# (APPENDIX) Annexe {-}



# RMarkdown

## Présentation 

### c koi?

R + Markdown.

Markdown est un langage simple pour mettre en forme des documents. C'est pratique si on veut construire des pages web sans connaître HTML, CSS et tout ça^[Sauf qu'une fois que tu utilises RMarkdown d'une manière intensive, tu commences à te lasser des modèles par défaut, et donc tu commences à explorer HTML et CSS. _Next thing you know_, tout est coloré.].

RMarkdown est un complément de Markdown: on peut exécuter des scripts R tout en utilisant la syntaxe de Markdown. Il existe deux extensions de nom pour Rmarkdown: `.Rmd` et `.Rmarkdown`. On ne se soucie pas de la différence entre les deux ici, il faut juste savoir que `.Rmd` est l'extension de base quand on créé un nouveau fichier Rmarkdown.

### à koi ça sert?

On peut construire des documents avec le code R directement dedans. C'est bien pour inclure dans le texte des tableaux, des graphiques, des modèles, des formules mathématiques...issus du code (et donc qui se mettrons à jour si on effectue un changement) au lieu de faire une capture d'écran, coller la capture sur Word ou perdre du temps à mettre des tableaux en forme.

C'est aussi très utile pour pouvoir reproduire des résultats^[Par souci de transparence, pour prouver qu'on a vraiment fait ce qu'on présente.], quand on diffuse son fichier avec d'autres personnes.

### keske je peux faire avec?

Beaucoup de choses, parmi lesquelles:

* un ou des fichiers HTML:
  * un fichier unique (comme on nous demande parfois dans le cadre du master),
  * un site!
  * des diapositives (il existe déjà des modèles dans R, à titre personnel j'utilise [`xaringan`](https://github.com/yihui/xaringan) parce que je n'aime pas ces modèles de base),
  * un CV (par exemple avec `pagedown`),
  * et autre...
* un fichier pdf ($\LaTeX$ doit être installé sur la machine). On peut exporter les fichiers HTML (dans le cas de CV et de diapos) en pdf avec `pagedown::chrome_print(fichier.Rmd)`.
* un document Word (bof).

Dans l'[en-tête du fichier](#en-tete) `.Rmd`, on définit le type de document qu'on souhaite obtenir, on écrit à gauche à droite, puis on compile!

### Packages utiles pour les rendus

* [`kableExtra`](https://cran.r-project.org/web/packages/kableExtra/vignettes/awesome_table_in_html.html) pour les tableaux,
* `stargazer` pour les régressions,
* [`gtsummary`](https://github.com/ddsjoberg/gtsummary) pour les tableaux descriptifs et les régressions ! Je n'ai pas encore testé ce package.

## Syntaxe

[Source très complète](https://www.markdownguide.org/basic-syntax/#lists-1) `[Source très complète](lien)` pour voir la syntaxe de base. La liste présentée ici n'est pas exhaustive.

### Texte

* **Gras** : `**gras**`
* _Italique_ : `_Italique_` ou `*Italique*`
* `code simple`: `` `code simple` `` qu'on utilise dans le corps du texte (par exemple: pour les noms de packages `tidyverse`). On utilise ```` ``` code ``` ```` pour créer un bloc.
* `` `\r code` `` (sans l'anti-slash avant le r) pour que le code s'exécute dans le corps du texte. `` `\r mean()` `` écrira la moyenne.
* $a^2 + b^2 = c^2$ : `` `$ a^2 + b^2 = c^2 $` `` pour les équations dans le corps du texte (sans les apostrophes avant et après les `$`, je n'arrive pas à les masquer ici). Pour qu'une équation prenne une ou plusieurs lignes à part, on encadre avec deux `$$` de chaque côté: `` `$$ a^2 + b^2 = c^2 $$` `` donne 
$$ a^2 + b^2 = c^2 $$
* Note de bas de page^[[Coucou](https://youtu.be/dQw4w9WgXcQ).] : Note de bas de page\[^1] (selon le package, c'est comme ça ou texte\^[note de bas de page]).

\[^1]: Texte de  la note de bas de page.

### Titres 

Les titres de différents niveaux, `# Titre niveau 1`, `## Titre niveau 2`, etc. En règle générale, on utilise qu'un titre de premier niveau par document. Ce niveau correspond au nom du document entier, les niveaux inférieurs à des chapitres, sections, etc.

<div class = "split">
<div class = "split1">

```markdown
# Niv. 1 - La planète Terre

## Niv. 2 - L'Europe

### Niv. 3 - La France

#### Niv. 4 - L'Auvergne-Rhône-Alpes

##### Niv. 5 - L'Ain

###### Niv. 6 - Une ville perdue mais dynamique
```

</div>
<div class = "no-anchor">

<h1 style="margin-top: 0em;">Niv. 1 - La planète Terre</h1>
<h2 style="margin-top: 0em;">Niv. 2 - L'Europe</h2>
<h3 style="margin-top: 0em;">Niv. 3 - La France</h3>
<h4 style="margin-top: 0em;">Niv. 4 - L'Auvergne-Rhône-Alpes</h4>
<h5 style="margin-top: 0em;">Niv. 5 - L'Ain</h5>
<h6 style="margin-top: 0em;">Niv. 6 - Une ville perdue mais dynamique</h6>

</div>
</div>

\

### Liste

* This
* Is
  - How
  - We
    * Do iiiit
* This is how we do it^[Pas besoin de changer les signes comme je l'ai fait ici, on peut utiliser `*` tout le temps si on le souhaite.]


```markdown
* This
* Is
  - How
  - We
    * Do iiiit
+ This is how we do it
```

1. Kilomètre à pied
    1. ça use,
    2. ça use
2. Kilomètres à pied
    1. ça use les souliers
3. Kilomètres à pied...

```markdown
1. Kilomètre à pied
    1. ça use,
    2. ça use
2. Kilomètres à pied
    1. ça use les souliers
3. Kilomètres à pied...
```

### Tableau

|Observation|Variable 1|Variable 2|
|-|-|-|
|$n_1$|$x_{1,1}$|$x_{1,2}$|
|$n_2$|$x_{2,1}$|$x_{2,2}$|
|$n_3$|$x_{3,1}$|$x_{3,2}$|

```
|Observation|Variable 1|Variable 2|
|-|-|-|
|$n_1$|$x_{1,1}$|$x_{1,2}$|
|$n_2$|$x_{2,1}$|$x_{2,2}$|
|$n_3$|$x_{3,1}$|$x_{3,2}$|
```

### Bibliographie

RMarkdown gère aussi la bibliographie, en tandem avec Zotero ou autre logiciel de référencement. Toutefois je n'ai pas encore tenté, donc je n'en parle pas ici.

## En-tête du fichier {#en-tete}

En tête des documents RMarkdown, on trouve des lignes qui définissent le document (titre, auteur, date, apparence...), comprises entre six tirets. Cet en-tête est en YAML (_Yet Another Markup Language_).

Par exemple, pour ce livre il y a:
```yaml
---
title: "Toutes les méthodes du master"
author: "KF"
site: bookdown::bookdown_site
output: 
  bookdown::gitbook:
    config:
      toc:
        collapse: section
      sharing: null
documentclass: book
link-citations: yes
github-repo: pyrrhamide/regressions
---
```

Pour un document pdf, il pourrait y avoir:
```yaml
---
title: "Titre"
author: "Auteur"
date: "13-12-2019"
output:
  pdf_document:
    keep_tex: yes
    number_sections: yes
urlcolor: blue
geometry: margin = 2cm
fontsize: 11pt
---
```

Pour un document HTML:
```yaml
---
title: "Titre"
subtitle: "Sous-titre"
author: "Auteur"
date: "02/11/2020"
output:
  html_document:
    toc: yes
    toc_float:
      collapsed: yes
    number_sections: yes
---
```

Il y a plein d'options à découvrir sur le World Wide Web.

## Morceaux de code

Dans les scripts R standards, le code prime sur le texte. Si on veut ajouter du texte, on doit faire des commentaires. Pour les fichiers RMarkdown, le texte a la priorité sur le code. Le fichier se présente alors ainsi: en-tête YAML - texte - code - texte...

Pour insérer un morceau de code: soit on choisit dans le menu, soit `Ctrl + Alt + I`. On obtient un bloc vide:
````markdown
```{r}

```

````
Dans les accolades, on peut donner un nom à ce bloc après `r`, puis on peut ajouter des options séparées par des virgules. Voici une liste non-exhaustive des options les plus utilisées:

* `echo = T/F` pour afficher le code dans le document final,
* `eval = T/F` pour exécuter le code ou non,
* `include = T/F` pour inclure le code **et les résultats/messages** dans le document final,
* `message = T/F` pour afficher les messages (par exemple je mets `FALSE` quand je charge mes packages, parce que certains d'entre eux "parlent" beaucoup),
* `results = 'ton choix'` pour afficher les résultats.

On peut ajouter ces options à chaque bloc de code, individuellement. On peut aussi définir un comportement global des blocs, pour tout le document:

````markdown
```{r setup, include = FALSE}
knitr::opts_chunk$set(echo = TRUE, ...)
```

````



Si on a besoin qu'un bloc est un comportement différent de celui de défaut, il suffit simplement d'ajouter les options voulues dans les accolades de ce seul bloc.

Il existe d'autres options pour la mise en page des images et graphiques, que je ne détaille pas ici.

On rédige ensuite nos lignes de code et nos commentaires. Pour visualiser le document final, il faut compiler le fichier Rmd en cliquant sur le bouton `Knit`, ou bien avec le raccourci clavier `Ctrl + Maj + K`.
