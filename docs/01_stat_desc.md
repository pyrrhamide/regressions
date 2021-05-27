# (PART\*) Démarrage {-}

# Statistiques descriptives {- #stat-desc}




```r
## Packages à charger, nécessaire pour l'analyse ##
library(tidyverse)
library(questionr) # pour effectuer des tris à plat et des tris croisés
library(survey) # pour travailler avec des données pondérées
```

On importe les données puis on les observe. Ci-dessous j'ai mis des fonctions de bases avec un dataframe qui n'existe pas. J'ai lu récemment que ce n'était pas très *data analyst* que de faire `View(data_frame)` pour visualiser les données. À la place, il faut utiliser la console (ou ton script) pour en apprendre le plus possible sur tes données^[Après, ce n'est pas la fin du monde si tu décides de visualiser ta base entièrement. Personnellement, je le fais.]


```r
dim(d) # nb lignes (observations) et nb colonnes (variables-normalement)
names(d) 
str(d) # type des variables

sum(is.na(d))

summary(d$x)
unique(d$x)
levels(d$x) # au choix

table(d$x,d$y,useNA="ifany")
prop.table(table(d$x,d$y,useNA="ifany"))
rprop(table(d$x,d$y))

# avec le tidyverse, dont je suis une grande fan
d %>% count(x,y)

# corrélation
cor(d$x,d$y,method='pearson')

# test du khi-deux
chisq.test(d$x, d$y)
```

Toutefois, ces mesures ne suffisent pas pour décider de faire une régression linéaire ! Il faut également visualiser les données, pour être sûr.e que la répartition soit bien linéaire ou même pour conclure directement sur quelque chose. `ggplot2` gère tout ça. 

Il existe plein d'autres options pour les fonctions écrites ici. Tu peux les retrouver dans la documentation officielle en tapant `?fonction` dans la console, ou en plaçant ton curseur sur la fonction dans ton script et en appuyant sur `F1`. Appuyer `F2` ouvrira une page avec la syntaxe complète de la fonction.
