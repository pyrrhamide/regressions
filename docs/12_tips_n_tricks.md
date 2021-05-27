# Trucs et astuces



J'ai découvert beaucoup de petites astuces sur R et RStudio qui ont rendu mon workflow plus rapide et confortable. J'ai présenté les principales par-ci par-là dans le texte, maintenant je leurs dédie un chapitre entier.

Mes sources: _Tools > Keyboard Shortcuts Help_, Internet.

## Raccourcis clavier

Mes préférés: 

* `Ctrl + Entree` pour exécuter une ligne de code (normalement on connaît tous),
* `Ctrl + Maj + F10` pour redémarrer RStudio,
* `Ctrl + 2` pour naviguer sur la console,
* `Ctrl + Maj + N` pour un nouveau script,
* `Ctrl + W` pour fermer la fenêtre ouverte,
* `Ctrl + Maj + W` pour fermer toutes les fenêtres,
* `Ctrl + Maj + C` pour dé/commenter une ligne (!!!).

## Pipes de `magrittr`


```r
library(magrittr)
```

`magrittr` contient plusieurs pipes différents de `%>%` que je trouve utiles:

* `%<>%` pour assigner directement des changements à une base. De `d <- d %>% mutate()`, on passe à `d %<>% mutate()`.
* `%$%` pour utiliser une fonction qui n'est pas compatible avec le tidyverse, comme si oui. Je suis une flemmarde, et je trouve qu'une répétition de `base$variable` est moche. De `fonction(d$x, d$y, d$z)`, on passe à `d %$% fonction(x, y, z)`.

## Autres trucs 


```r
library(here)
library(purrr) # inclut dans tidyverse
```


```r
d %>% select(x, y, z) %>% map(~ fonction(.))
```
