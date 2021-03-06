
# Nettoyage des données {- #nettoyage}



Il faut nettoyer pour éviter le plus d'erreur au niveau des commandes. Ca veut dire gérer les non-réponses, changer la nature des variables, changer leurs noms, réordonner les modalités...

J'adhère à la philosophie d'Hadley Wickham: une ligne = une observation, et une colonne = une variable. Dans le cas des données de panel, ça veut dire avoir plusieurs lignes par année pour une unité (individu, pays...), au lieu d'une ligne pour une unité, et la même variable multipliée par le nombre d'années. Je ne m'attarde pas dessus. Si tes données sont semi-propres, intéresse toi à la fonction `tidyr::pivot_longer`.

On nettoie les données en prévision des régressions futures. On dichotomise notamment les modalités des variables explicatives catégorielles^[*Codage disjonctif complet* - on nous recommandait ça pendant le M1, mais R peut dichotomiser les modalités des variables comme un grand, tant que les variables sont du type facteur.].

Par exemple :

On a une variable couleur qui prend comme $n$ modalités 1 = bleu ; 2 = blanc ; 3 = rouge. On va la transformer en $n-1$ (dans ce cas, 2) variables binaires, une indiquant si c'est bleu (0 = non ; 1 = oui), une indiquant si c'est blanc (*idem*). Il n'y a pas besoin de créer une troisième variable dichotomique car, par défaut, une observation qui est à bleu = 0 et blanc = 0 serait à rouge = 1:


```r
# codage disjonctif complet
d$bleu[d$couleur==1] <- 1
d$bleu[d$couleur!=1] <- 0

d$blanc[d$couleur==2] <- 1
d$blanc[d$couleur!=2] <- 0

# plus propre avec tidyverse
d <- d %>% mutate(bleu = ifelse(couleur==1,1,0),
                  blanc = ifelse(couleur==2,1,0))
```

En gros, pour une variable à $n$ modalités/catégories que tu veux utiliser dans une régression, tu génères $n-1$ variables dichotomiques. Toutefois, ce n'est pas du tout nécessaire parce que les fonctions de régressions de R dichotomisent automatiquement les modalités des variables catégorielles du moment qu'elles sont de type facteur.

Si tu as une variable à $n$ modalités, tu peux aussi choisir de regrouper deux modalités ensemble et de les coder en 0 et le reste des modalités en 1.

**Important** : une fois que tu as déterminé toutes tes variables explicatives, transforme les en facteur et change leur niveau/ordre. Les régressions fonctionnent avec des variables facteurs.

Exemple : prenons une variable des mentions du bac qui est à l'origine sous la forme caractère. Sous le format caractère, les mentions seront rangées par ordre alphabétique et non par ordre hiérarchique "évident". Il revient à toi d'ordonner les modalités comme tu le souhaites. La première modalité sera la modalité de référence.


```r
d$mentions <- factor(d$mentions, levels=c('Sans mention','Passable','Assez bien','Bien','Très bien'))

# Note: il existe d'autres fonctions du pkg forcats pour accélérer l'ordonnancement des modalités. 
# Je te laisse les découvrir, moi j'ai pas le time, j'ai curling sur gazon.
```
