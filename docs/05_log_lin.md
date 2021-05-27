
# Régression log-linéaire {#log-lin}




```r
# Les packages et fonctions
library(vcd)
library(vcdExtra)
library(DescTools)

library(tidyverse)

# source("f.util.cours.R") fonction créée par Maxime Parodi
stat_ajust <- function(...) {
  list_glm <- enquos(...)
  noms <- as.character(list_glm) %>% map_chr(~str_sub(.x, start = 2))
  list_glm <- map(list_glm, rlang::eval_tidy)

  return(map2_dfr(list_glm, noms, ~ tibble(
    model = .y,
    G2 = .x$deviance,
    ddl = .x$df.residual,
    p.value.G2 = 1 - pchisq(.x$deviance, .x$df.residual),
    dissimilarity = sum(abs(.x$y - .x$fitted.values)) / sum(.x$y) / 2,
    AIC = .x$aic,
    BIC = AIC(.x, k = log(sum(.x$y)))
    )))
}
  # il me semble que cette fonction ne fonctionne pas avec les données pondérées. utilise stat_ajust2 dans ce cas, dispo dans son fichier.

# La base
Berkeley <- UCBAdmissions %>% as.data.frame()
```

------------------------------------------------------------------------

_Copie du fichier `FormuleLogLin.Rmd` de Maxime Parodi._

Soit un modèle log-linéaire avec trois variables A, B et C ayant chacune des modalités indexées respectivement par les indices $i$, $j$ et $k$. La table de contingence contient les effectifs notés $m_{ijk}$.\
Un modèle log-linéaire est une régression sur le log des effectifs dans chacun des cases du tableau de contingence, soit : $$log(m_{ijk}) = constante + \\ margeA_i + margeB_j + margeC_k + \\ interactionAB_{ij} + interactionAC_{ik} + interactionBC_{jk} + \\ interactionABC_{ijk}$$ Un modèle log-linéaire contient toujours la constante et toutes les marges du tableau de contingence. Puis on peut ensuite ajouter des interactions. Il s'agit quasiment toujours de modèles hiérarchiques, càd que, dès lors que l'on met une interaction d'ordre n entre un sous-groupe de variables, toutes les interactions d'ordre inférieur à n entre les variables de ce sous-groupe sont également incluses dans le modèle.\
La constante permet d'estimer l'effectif total de la table. Les coefficients $margeA_i$ permettent d'estimer les effectifs de la $i^{ème}$ ligne de la table, qui correspond à la $i^{ème}$ modalité de A.

------------------------------------------------------------------------

Résumons les différents modèles de régression qu'on a vu jusqu'à maintenant :\
- **régression linéaire simple/multiple** : variable à expliquer quantitative, toutes les variables sont dans leurs unités de bases.\
- **régression linéaire de probabilité** : variable à expliquer dichotomique, toutes les variables sont dans leurs unités de bases.\
- **régression logistique dichotomique/polytomique** : variable à expliquer dichotomique, toutes les variables sont mises à l'échelle logarithmique ($log(x)$).

On passe maintenant à la **régression log-linéaire**, que je résume (rapidement et sans doute pas correctement) ainsi : la variable à expliquer est mise à l'échelle logarithmique, les variables explicatives restent dans leurs unités de bases. On fait un tri croisé avec ces variables. Ce modèle mesure l'indépendance (ou non) statistique. J'utilise maintenant l'exemple des admissions à Berkeley : $admissions*département*sexe$.


## Modèle de l'indépendance


```r
# Modèle log-linéaire
# Modèle de l'indépendance totale
M0 <- glm(Freq ~ Gender + Admit + Dept, family = poisson, data = UCBAdmissions)
# La différence avec la reg logit est la famille de la distribution. Pour la reg logit, on avait family=binomial, ici on a family=poisson.

summary(M0)
```

```

Call:
glm(formula = Freq ~ Gender + Admit + Dept, family = poisson, 
    data = UCBAdmissions)

Deviance Residuals: 
    Min       1Q   Median       3Q      Max  
-18.170   -7.719   -1.008    4.734   17.153  

Coefficients:
              Estimate Std. Error z value Pr(>|z|)    
(Intercept)    5.37111    0.03964 135.498  < 2e-16 ***
GenderFemale  -0.38287    0.03027 -12.647  < 2e-16 ***
AdmitRejected  0.45674    0.03051  14.972  < 2e-16 ***
DeptB         -0.46679    0.05274  -8.852  < 2e-16 ***
DeptC         -0.01621    0.04649  -0.349 0.727355    
DeptD         -0.16384    0.04832  -3.391 0.000696 ***
DeptE         -0.46850    0.05276  -8.879  < 2e-16 ***
DeptF         -0.26752    0.04972  -5.380 7.44e-08 ***
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

(Dispersion parameter for poisson family taken to be 1)

    Null deviance: 2650.1  on 23  degrees of freedom
Residual deviance: 2097.7  on 16  degrees of freedom
AIC: 2272.7

Number of Fisher Scoring iterations: 5
```

```r
# Residual deviance = 2097.7 on 16 degrees of freedom.
```

Il reste beaucoup trop d'information à expliquer que le modèle de l'indépendance totale n'explique pas, trop pour établir l'indépendance entre les variables. On décide alors de mettre à jour le modèle en ajoutant des interactions.

## Modèles avec interaction


```r
# une interaction prise en compte
M1_GD <- update(M0, . ~ . + Gender:Dept) # choix du département est genré
M1_GA <- update(M0, . ~ . + Gender:Admit) # admission discriminante en fonction du sexe
M1_AD <- update(M0, . ~ . + Admit:Dept) # départements plus ou moins selectifs

# deux interactions
M2_GD.GA <- update(M1_GD, . ~ . + Admit:Gender)
M2_GD.AD <- update(M1_GD, . ~ . + Admit:Dept)
M2_AD.GA <- update(M1_AD, . ~ . + Admit:Gender)

# trois interactions d'ordre 2
M3 <- update(M2_GD.AD, . ~ . + Gender:Admit)

# une interaction d'ordre 3 = modèle saturé
M4 <- update(M0, . ~ . + Gender*Admit*Dept) 
# sélectivité du département varie selon le sexe
```

Tous les modèles sont stockés dans la mémoire de R, on veut maintenant voir le gain ou la perte d'information offert.e par chaque nouveau modèle.

## Analyse de deviance {#analyse-de-deviance}


```r
anova(M0, M1_GA, M1_AD, M1_GD, M2_AD.GA, M2_GD.GA, M2_GD.AD, M3, M4)
```

```
Analysis of Deviance Table

Model 1: Freq ~ Gender + Admit + Dept
Model 2: Freq ~ Gender + Admit + Dept + Gender:Admit
Model 3: Freq ~ Gender + Admit + Dept + Admit:Dept
Model 4: Freq ~ Gender + Admit + Dept + Gender:Dept
Model 5: Freq ~ Gender + Admit + Dept + Admit:Dept + Gender:Admit
Model 6: Freq ~ Gender + Admit + Dept + Gender:Dept + Gender:Admit
Model 7: Freq ~ Gender + Admit + Dept + Gender:Dept + Admit:Dept
Model 8: Freq ~ Gender + Admit + Dept + Gender:Dept + Admit:Dept + Gender:Admit
Model 9: Freq ~ Gender + Admit + Dept + Gender:Admit + Gender:Dept + Admit:Dept + 
    Gender:Admit:Dept
  Resid. Df Resid. Dev Df Deviance
1        16    2097.67            
2        15    2004.22  1    93.45
3        11    1242.35  4   761.87
4        11     877.06  0   365.29
5        10    1148.90  1  -271.84
6        10     783.61  0   365.29
7         6      21.74  4   761.87
8         5      20.20  1     1.53
9         0       0.00  5    20.20
```

En regardant la dernière colonne, "Deviance", on peut voir que les modèles 3 (les départements sont sélectifs) et 7 (les départements sont sélectifs et genrés) sont ceux grâce auxquels on a gagné le plus d'information. Le modèle 3 indique l'interaction qui explique le mieux la variance du tableau. Le modèle 7 est le best overall, ayant le moins de residual deviance, c'est donc le modèle qui expliquerait le mieux la variance des données. Visiblement, la sélectivité des départements et leurs compositions sont des éléments importants à inclure dans la régression.

Pourquoi ne pas prendre le modèle 9 ? Parce que le modèle 9 est saturé (toutes les combinaisons d'interactions sont dans le modèle, c'est logique que toutes les données soient expliquées.)

Revenons en au modèle 7. Comment peut-on s'assurer que le gain d'info est réel et pas dû au hasard (n'est pas du bruit)?


```r
stat_ajust(M0, M1_GA, M1_AD, M1_GD, M2_AD.GA, M2_GD.GA, M2_GD.AD, M3, M4)
```

```
# A tibble: 9 x 7
  model           G2   ddl p.value.G2 dissimilarity   AIC   BIC
  <chr>        <dbl> <int>      <dbl>         <dbl> <dbl> <dbl>
1 M0        2.10e+ 3    16    0            2.60e- 1 2273. 2324.
2 M1_GA     2.00e+ 3    15    0            2.57e- 1 2181. 2239.
3 M1_AD     1.24e+ 3    11    0            2.13e- 1 1427. 1511.
4 M1_GD     8.77e+ 2    11    0            1.69e- 1 1062. 1146.
5 M2_AD.GA  1.15e+ 3    10    0            1.89e- 1 1336. 1426.
6 M2_GD.GA  7.84e+ 2    10    0            1.56e- 1  971. 1061.
7 M2_GD.AD  2.17e+ 1     6    0.00135      1.64e- 2  217.  332.
8 M3        2.02e+ 1     5    0.00114      1.67e- 2  217.  339.
9 M4       -3.38e-14     0    1            1.81e-15  207.  361.
```

(1) Regardons la colonne "p.value.G2": une $p.value$ de 0 est suspicieux, on ne prend pas en compte les modèles qui ont cette valeur ;\
(2) "Dissimilarity" : proportion des observations 'mal classées'. Le plus bas, le mieux. De ce fait, le modèle 7 est toujours le meilleur, ce qui est confirmé par son BIC qui est le plus faible de tous les modèles (jsp ce que ça mesure par contre.)

Les coefficients d'un modèle log-linéaire avec interaction peuvent être obtenus avec une régression logistique dichotomique. 

## Odds ratio

Les coefficients ne sont pas interprétables directement, on utilise les [odds ratio](#odds-ratio-complet).
