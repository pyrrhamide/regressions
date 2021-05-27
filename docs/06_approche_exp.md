# Modélisation et identification causale, vol. 2 {#mod-id2}

_Copie des diapositives du cours d'Olivier Godechot._




```r
library(lfe)
library(AER)
library(survival)
library(plm)
library(lmtest)
```

Je mets immédiatement les lignes de codes complètes ici. Je recommande d'utiliser la fonction `felm()` du package `lfe` pour toutes les techniques de ce cours, mais il est aussi possible d'utiliser `lm()`, `plm::plm()` ou `AER::ivreg()` pour de petites vérifications.

La fonction `felm()` fait tout: les effets fixes, les effets aléatoires, les variables instrumentales, la clusterisation des erreurs-types...it's the GOAT 🐐.

```r
## La syntaxe des commandes principales ##
felm(y ~ x1 + x2 | f1 + f2 | x3 + x4 | clu1 + clu2, data, weights, ...)
# soit
felm(var_dep ~ vars_indep | vars_effet_fixe | vars_instrumentales | vars_cluster_se, data, weights, ...)
# si on veut seulement clusteriser les erreurs-types, on remplace
# vars_effet_fixe et/ou vars_instrumentales par 0
felm(y ~ x1+x2 |0|0|clu1+clu2, data, weights, ...)

# Pour les variables instrumentales - plus détaillé plus tard
ivreg(y ~ x1 + x2 | z1 + z2, data, weights, ...)
# soit
ivreg(var_dep ~ var_endo + vars_indep | vars_exo_inst, data, weights, ...)

# Pour les données de panel/effets fixes et tout ça
plm(y ~ x1 + x2, index=c("var_indiv","var_temps"), data, model = "pooling")
  # voir la documentation pour les autres "model" et également les "effect".
```

## Approches expérimentales

Groupe traité v groupe de contrôle.

Pour connaître l'effet du traitement, groupe 'traité' diffère du groupe de contrôle seulement du traitement.

4 méthodes autour de cette idée:

1. Expériences aléatoires contrôlées
2. Expériences naturelles
3. Différences de différences
4. Régression par discontinuité

### Expériences aléatoires contrôlées
2 exemples d'expériences aléatoires contrôlées:

* Expérience à essais randomisés contrôlés (*randomised controlled trials (RCT) experiments*)
* Expériences par questionnaire (*randomised survey experiment*)

On prend un groupe uniforme, qui rempli les mêmes caractéristiques, à qui on applique un ou des traitements différents pour voir si les résultats sur une variable à expliquer diffèrent.

Il y a du soleil. **Aléatoirement**, on soumet les individus à des traitements différents (c'est la ventilation aléatoire): une partie du groupe se met à l'ombre, une autre applique de la crème solaire, et une autre ne fait rien (c'est le groupe de contrôle - indépendance du traitement). Avec cette expérience, quel est le traitement qui réduit le plus les chances d'attraper un coup de soleil ?

**Pourquoi l'expérience randomisée ?**

* Ventilation aléatoire assure que toutes les caractéristiques des individus (à la fois observées et surtout inobservées) vont être ventilées de manière équiprobable dans les groupes traités ou de contrôle.
* L'estimation n'est plus biaisée par une variable confondante (hétérogénéité inobservée)
* Simplification considérable de la statistique
  * intensité indiquée par la différence (ou le rapport) des moyennes
  * significativité test de différence de moyennes ou de proportions [préciser le.s tests en question]
* Expérience aléatoire versus échantillon aléatoire
  * échantillon aléatoire: établir des statistiques représentatives d'une population $\rightarrow$ validité externe [définir ce que c'est].
  * expérience aléatoire: ventilation aléatoire d'un échantillon $\rightarrow$ validité interne [définir].

**L'expérience et ses aveugles**

* Simple aveugle: le patient ne sait pas dans quel groupe il est (traité ou placebo)
* Double aveugle: le patient et la personne qui administre le traitement ne savent pas dans quel groupe se trouve le patient
* Triple aveugle: le patient, la personne qui administre le traitement et le statisticien ne savent pas dans quel groupe se trouve le patient.

L'expérience aléatoire en sciences sociales est rarement une expérience avec placebo et en aveugle. Le placebo, qui doit avoir la forme, le goût, etc. du placebo, n'existe pas toujours [trouver exemple]. Il y a souvent 2 groupes: un qui fait l'objet d'une intervention et un qui ne reçoit rien. Il importe alors d'être vigilent à faire une analyse en intention de traiter (*intention to treat*) plutôt que traitement réalisé (*treatment on treated*).

[parler des limites techniques et conceptuelles?]

### Expériences naturelles

* Situation "naturelle" qui ressemble à une situation expérimentale (ventilation aléatoire ou quasi-aléatoire d'une population entre groupe traité et groupe de contrôle) sans avoir été construite à des fins expérimentales.
* Tirages au sort comme procédure d'allocation (e.g. jurés en tribunal, distribution dans les chambres d'internat, répartition entre ceux qui ont dû présenter leur problématique de mémoire le jour 1 et le jour 2)
* Autres exemples : jeux aléatoires et loteries, phénomène aléatoires ou quasi aléatoires (sexe de l'enfant/mois de naissance), recrutement académique...

[EXEMPLE!!!]

### Différences-de-différences (*differences-in-differences*)

On reprend l'opposition groupe traité versus groupe de contrôle des expériences contrôlées. Toutefois, on n'est pas sûr que les groupes de contrôles soient vraiment similaires en tout point excepté le traitement. On va faire une hypothèse plus faible: la différence entre traitement et contrôle est constante dans le temps.

  * différence prétraitement est la différence liée aux "inobservables"
  * différence post-traitement est la différence liée aux "inobservables" + effet causal
  * différence de différence est l'effet causal (diff post - diff pré)

Différence "standard" :
$$Traité - Contrôle \\ T_1 - C_1$$
Différence de différence est l'estimation :
$$DiD = (Traité_{post}-Traité_{anté})-(Contrôle_{post}-Contrôle_{anté}) \\ DiD = (T_1-T_0)-(C_1-C_0)$$

Notations classiques :\
- $T_1=\mu_{11}$ ; $T_0=\mu_{10}$ ; $C_1=\mu_{01}$ ; $C_0=\mu_{00}$\
- Diff-in-Diff = $(\mu_{11}-\mu_{01})-(\mu_{10}-\mu_{00})$

**Estimations économétriques**\
Quand on a un panel :\
- on mesure sur les mêmes individus, l'avant et l'après,\
- on estime l'évolution,\
- $\Delta y_i = \beta_0 + \beta_1 GT + \epsilon_i$ ou GT est le groupe traité,\
  - $\Delta y_i$ est l'évolution/la variation de $y_i$
  - $\beta_0$ est l'intercept [nom spécial en DiD?]
  - $\beta_1$ est l'estimateur DiD.
  - $\epsilon_i$ est le terme d'erreur [distribution spéciale?]

Quand on n'a pas de panel :\
- les individus avant et après ne sont pas les mêmes,\
- $y_{it} = \beta_0 + \beta_1 GT + \beta_2 t + \beta_3 t \times GT + \epsilon_{it}$,\
- $\beta_3$ est l'estimateur DiD.

**Portées et limites**

* Hypothèses fortes:
  * la différence entre le traitement et le contrôle serait restée constante en l'absence de traitement.
  * ou redit autrement, la différence de différence est uniquement due au "traitement" et non à un autre changement intervenu dans le groupe traité entre la période 1 et 2.
* Si on dispose de plus de deux périodes, on peut faire une vérification graphique.

### Régression par discontinuité (*Regression discontinuity design*)

Les groupes sont ventilés pour recevoir ou non un traitement en fonction d'un seuil sur une variable mesurable (continue). Par exemple, les personnes qui sont arrêtées au-delà d'un seuil d'alcool dans le sang ont l'obligation de suivre un traitement, et les groupes au-dessous de ce seuil servent de groupe de comparaison (groupe de contrôle). L'effet est mesuré au niveau de la discontinuité entre le groupe traité et le groupe de contrôle (on ne fait pas la différence de moyenne entre deux groupes).

**Conditions d'applications**

Le seuil est exogène, non manipulable, et déclenche les actions:

* majorité absolue $\rightarrow$ effet de l'élection
* rang du dernier poste offert au concours $\rightarrow$ effet de l'école
* seuil de déclenchement d'une mesure sociale ou fiscale $\rightarrow$ effet de la politique, etc...

**Avantages et désavantages**

Avantages: quand c'est bien effectué, la régression par discontinuité permet une estimation non biaisée du traitement.

Désavantages:

* la puissance statistique est bien moindre que dans des essais randomisés contrôlés portant sur le même effectif. L'attention à la puissance statistique est cruciale.
* les effets sont sans biais uniquement si la forme fonctionnelle entre la variable d'assignation et la variable de résultat est bien modélisée, y compris:
  * des relations non-linéaires (augmentation - plateau - augmentation)
  * des interactions (pente coef 1 - seuil - pente coef 2)

**Estimations économétriques**\
Le modèle linéaire simple (premières estimations)\
- $y_i = \beta_0 + \beta_1 x + \beta_2 (x>seuil) + \epsilon_i$,\
- L'effet causal est mesuré par $\beta_2$,\
- Limite suppose que la forme fonctionnelle est la même de part et d'autre du seuil (en gros, que le coefficient de la pente soit pas trop différent à gauche et à droite de la discontinuité).

Le modèle linéaire avec changement de pente\
- $y_i = \beta_0 + \beta_1 x + \beta_2 (x>seuil) + \beta_3x \times (x>seuil) + \epsilon_i$\
- l'effet causal est mesuré par $\beta_2$.
- différence avec modèle linéaire simple: on interagit $x$ pré-seuil et post-seuil.

Le modèle linéaire avec changement de forme\
- attention de bien centrer la variable $x$ autour du seuil ! $x' = x-seuil$,\
- $y_i = \beta_0 + \beta_1 x' + \beta_2 x^{'2} + \beta_3(x'>0) + \beta_4x' \times (x'>0) + \beta_5 x^{'2} \times (x'>0) + \epsilon_i$,\
- l'effet causal est mesuré par $\beta_3$.


```r
# Regression discontinuity design - je recommande de regarder directement le code du prof et de lancer les commandes.

# recentrage de la variable autour du seuil
d$var_cont_cent <- d$var_continue - valeur_seuil_au_choix # commande parmi plein d'autres, là c'est toi qui prend l'initiative

pr1 <- lm(var_dep ~ var_continue+I(var_continue>=valeur_seuil_au_choix),data=d)
# suppose que pente est la même à gauche et à droite du seuil

pr1 <- lm(var_dep ~ var_cont_cent+I(var_cont_cent>=0),data=d)

pr2 <- lm(var_dep ~ var_continue+I(var_continue>=valeur_seuil_au_choix)+
          I((var_continue>=valeur_seuil_au_choix)*var_continue),data=d)

# pour cacher les points extrêmes de la base (pour garder la linéarité)
pr2b <- lm(var_dep ~ var_continue+I(var_continue>=valeur_seuil_au_choix)+
            I((var_continue>=valeur_seuil_au_choix)*var_continue),
           data=d[d$var_continue>=valeur1 & d$var_continue<=valeur2,])
# pr2 et pr2b supposent que l'effet est linéaire des deux cotés du seuil


pr3 <- lm(var_dep ~ var_cont_cent+
            I(var_cont_cent>=0)+
            I((var_cont_cent>=0)*var_cont_cent)+
            I((var_cont_cent>=0)*var_cont_cent2),data=d)
```

## Variables instrumentales
Violation de la 6ème hypothèse des MCO ($Cov(x_i,\epsilon_i \neq 0)$ absence de corrélation entre les variables explicatives et le résidu) $\Rightarrow$ *endogénéité*. Pb endogénéité peut conduire à se tromper dans l'interprétation des paramètres. Variables instrumentales comme technique de correction.

3 problèmes et leurs effets sur les paramètres:

* Erreur de mesure d'une variable explicative: sous-estimation de la valeur absolue du paramètre $\beta_i$.
* Variable omise ou hétérogénéité inobservée (corrélée à la variable dépendante et à une autre variable explicative): sur/sous-estimation de la valeur absolue du paramètre.
* Simultanéité (variable explicative dépend de la variable expliquée): effet plus complexe. Pas d'intuition évidente.

Solution $\Rightarrow$ variable instrumentale: trouver une variable instrumentale exogène qui impacte ma variable expliquée $y_i$ uniquement par l'intermédiaire de son effet sur la variable explicative $x_i$ suspecte d'endogénéité.
$$ instrument \rightarrow var\_endo \rightarrow var\_dep$$

Sachant que $cov(x_{endo},\epsilon) \neq 0$, on introduit une variable instrumentale ($z_{inst}$) telle que:

* $cov(z_{inst},x_{endo}) \neq 0$, et
* $cov(z_{inst},\epsilon) = 0$

Vrai modèle^[Différent du modèle *théorique*.]: $y = a_{vrai} + b_{vrai} x_{endo} + c_{vrai} x_2 + \epsilon$ avec $cov(x_{endo},\epsilon) \neq 0$.

**Première étape**: on régresse la variable endogène à la fois sur l'instrument et sur les autres variables explicatives. NB: on met toutes les variables explicatives même non pertinentes en première étape.
$$x_{endo} = a_0 + a_1 z_{inst} + a_2 x_2 + \epsilon_{prem}$$

On récupère de cette première régression $x'_{endo}$, la prédiction de la variable endogène $x_{endo}$:
$$x'_{endo} = a_0 + a_1 z_{inst} + a_2 x_2 = x_{endo} - \epsilon_{prem}$$

**Deuxième étape**: on introduit cette prédiction dans la régression à la place $x_{endo}$.
$$y = a_{est} + b_{est} x'_{endo} + c_{est} x_2 + \epsilon_{deux}$$

Comme $z_{inst}$ et $x_2$ ne sont pas corrélés avec le résidu $\epsilon$, alors $x'_{endo}$ n'est plus corrélé avec $\epsilon$, l'estimateur des variables instrumentales permet d'estimer sans biais $b_{vrai}$ (et le reste).


```r
## 1ère façon de procéder ##
# MCO "naïve"
mco <- lm(y ~ x_endo + x1 + x2, data, weights, ...)

# Forme réduite - impact des instruments sur variable dépendante (facultatif)
fr <- lm(y ~ z1 + z2, data, weights, ...)

# Première étape: regression endogene sur autres variables indépendantes et instruments
pe <- lm(x_endo ~ x1 + x2 + z1 + z2, data, weights, ...)

# Deuxième étape: on introduit la prediction dans la régression "naïve"
mco2 <- lm(y ~ pe$fitted.values + x1 + x2, data, weights, ...)

## Deuxième façon de procéder ##
# Régression variable instrumentale directe, sans première étape
z <- ivreg(y ~ x_endo + x1 + x2 | z1 + z2, data, weights, ...)

# Pour voir les coefficients de la première étape
z$coefficients1

# Documentation officielle [vérifier si dans cours]:
# Note that exogenous regressors have to be included as instruments for themselves. For example, if there is one exogenous regressor ex and one endogenous regressor en with instrument in, the appropriate formula would be
ivreg(y ~ ex + en | ex + in)

## Troisième façon de procéder ##
# Régression avec instruments, sans effet fixe et sans clusterisation
felm(y ~ x_endo + x1 + x2 |0| z1+ z2 |0, data, weights, ...)
```

## Econométrie des panels
L'économétrie des panels rend visible et permet de traiter deux problèmes classiques :

1. L'autocorrélation des résidus,
2. L'hétérogénéité inobservée.

**Autocorrélation des résidus**

* $Cov(\epsilon_{it},\epsilon_{it+1}) = 0$ ?
* Si je suis sous-payée à la date $t$, je le serai sans doute à la date $t+1$.

**Hétérogénéité inobservée**

* Si $\epsilon_{it} = v.inobs + e$ et $cov(x_{ik},inobs) \neq 0 \Rightarrow$ biais.
* Le résidu $\epsilon_{it}$ peut être réécrit de la manière suivante: $\epsilon_{it} = \alpha_i + e_{it}$, comme la somme d'une erreur individuelle constante $\alpha_i$, et $e_{it}$ une erreur temporaire.
* $\alpha_i$ peut être vu comme déterminé par les variables inobservées *constantes dans le temps*.
* Question: peut-on dire que dans notre vrai modèle cette erreur constante $\alpha_i$ par individu est indépendante des variables explicatives, soit $cov(\alpha_i,x_k) = 0$ ?
  * Oui $\rightarrow$ estimation *pooling* ou aléatoire est la bonne.
  * Non $\rightarrow$ hypothèse des MCO $cov(\epsilon_i,x_k) = 0$ n'est pas respectée. Le modèle des MCO n'est pas consistant pour estimer les $\beta \rightarrow$ modèles à effets fixes ou en différences premières.

### Le modèle homogène, ou *pooled*

ou comment résoudre le problème d'autocorrélation des résidus.

Modèle estimé par les MCO: $y_{it}=\beta_0+\beta_1 x_{it}+...+\beta_k x_{kit} + \epsilon_{it}$

Le modèle *pooled/pooling* ou modèle homogène suppose que tous les résidus ont la même variance et qu'il n'y a pas d'autocorrélation des résidus.

```r
lm(y ~ x1 + x2, data)
# ou
plm(y ~ x1 + x2, data, index=c("individu","temps"), model = "pooling")
```

**La résolution du problème d'autocorrélation des résidus**

Deux possibilités:

1. Corriger la matrice de variance covariance:
    * estimateur sandwich de Huber-White/ *robust standard errors* : on corrige les écart-types pour tenir compte de l'hétéroscédasticité des résidus (mais pas de l'autocorrélation) $\rightarrow$ hétérogénéité des variances des résidus.
    * correction par cluster / *robust clustered standard errors* : on corrige les écart-types pour tenir compte à la fois de l'hétéroscédasticité des résidus et de leur autocorrélation par cluster (individus, nations, famille...) $\rightarrow$ hétérogénéité des variances des résidus + résidus clusterisés donc homogénéité des variances des résidus au sein des groupes.
2. Modéliser l'erreur comme la combinaison d'une erreur individuelle fixe et d'une erreur temporelle $\Rightarrow$ modèle à effet aléatoire (*random effect*).

```r
# Là il y a une flopée de méthodes possibles pour corriger les écart-types, mais la manière la plus simple est d'utiliser directement la fonction felm() en précisant la variable de groupe pour obtenir des erreurs-types robustes clusterisées.
# Utilise felm(), jdcjdr.
felm(y ~ x1 + x2 |0|0| var_cluster_se, data)
```

### Les modèles à effet aléatoire
On estime le modèle suivant:
$$y_{it} = \beta_0 + \beta_i x_{it} + \alpha_i + \epsilon_{it}$$

* Deux termes aléatoires $\alpha_i$ et $\epsilon_{it}$ qui ont chacun une loi de distribution propre.
* La technique d'estimation est celle des moindres carrés généralisés.
* L'avantage de ce modèle est de permettre une décomposition de la variance des résidus en un facteur individuel (i.e. *between*, et le cas échéant un facteur temporel) et un facteur idiosyncrasique [big words].

```r
plm(y ~ x1 + x2, data, index, model = "random")
```

### Le problème d'hétérogénéité inobservée

Modèle à effet aléatoire :
$$y_{it} = \beta_0 + \beta_i x_{it} + \alpha_i + \epsilon_{it}$$

* Si $cov(x_{kit},\alpha_i) = 0$, RAS.
* Mais l'erreur individuelle $\alpha_i$ peut être vue comme le produit de l'ensemble des variables inobservables invariantes dans le temps. Il n'est pas impossible que ces variables inobservables soient corrélées avec les observables.
* Plutôt que de modéliser les $\alpha_i$ par un effet aléatoire, on peut les modéliser par un effet fixe.

#### Modèle à effets fixes (*fixed effects*)

* Moindre carré à variables dichotomiques : *Least square dummy variables* ou LSDV. Introduire une variable dichotomique $\alpha_i$ par individu, possible uniquement si le nombre d'individus est petit (<1000).
* Modèle "*within*"* : modèle (sans constante) où l'on centre chaque variable (explicative ou expliquée), càd où l'on calcule l'écart à la moyenne de la variable pour l'individu.

$$(y_{it} - \bar y_i) = \beta_i (x_{it} - \bar x_i) + (\epsilon_{it} - \bar \epsilon_i)$$

```r
# Estimation des effets fixes

## Avec les effets fixes ##
lm(y ~ factor(var_indiv)+x1+x2, data)

## Avec l'estimateur within et le pkg plm ##
plm(y ~ x1 + x2, index, model = "within", data)

## Avec l'estimateur within et le pkg lfe ##
felm(y ~ x1 + x2 | var_indiv, data)
# en clusterisant les erreurs types par individu
felm(y ~ x1 + x2 | var_indiv |0| var_indiv, data)
```

**Deux effets fixes: groupes et temps**

On peut introduire un effet fixe par unité de groupe (e.g. individu, pays, etc.) et un effet fixe par unité de temps.

La conjoncture commune capturée par l'effet fixe temps:

* Tout avec des variables dichotomiques^[A éviter car prend beaucoup de place et de mémoire sur la console R.]:

$$y_{it}=\beta_i X_{it} + \alpha_i + \delta_t + \epsilon_{it}$$

* *Within* + variables dichotomiques de temps.

```r
plm(y ~ x1 + x2 + factor(var_temps), index, model="within", data)
```
* *Two ways within* (formule pour panel cylindrés)

```r
plm(y ~ x1 + x2, index, model="within", effect="twoways", data) # très lent
```

#### Effets fixes ou effets aléatoires ?

Comment choisir?

Test de Hausman: on regarde si l'estimation par effets fixes produit des résultats significativement différents d'un modèle à effets aléatoires.

* Si le test de Hausman est significatif, on privilégiera les effets fixes.
* Si le test de Hausman n'est pas significatif, on privilégiera les effets aléatoires.


```r
regfe <- plm(y ~ x1 + x2, data, index, model = "within")
regre <- plm(y ~ x1 + x2, data, index, model = "random")

phtest(regfe, regre)
# p-value significative -> effets fixes.
# p-value non significative -> effets aléatoires.
```

#### Modèles en différences premières (*first difference*)

Expliquer les évolutions par les évolutions (e.g différence revenu entre 1 année, puis 2, puis 5, etc...)
$$ (y_{it} - y_{it-1})=\beta_i (x_{it} - x_{it-1}) + (\epsilon_{it} - \epsilon_{it-1})$$
Le choix du retard:

* $[t,t-1] \rightarrow$ on se focalise sur des variations de court terme,
* $[t,t-k] \rightarrow$ variations de plus long terme, mais perte d'effectifs et de puissance.

Différence entre effets fixes & différences premières:

* panel à deux périodes: modèles équivalents (uniquement lorsque le modèle *within* comporte aussi un effet fixe temps).
* panel à plusieurs périodes: le modèle à effets fixes est une moyenne de variations de courtes et de longues périodes.

```r
plm(y ~ x1 + x2, index, model = "fd", data)
```

**Effets fixes et différences premières. Remarques**

* Double effet: réduction du problème d'autocorrélation et suppression du problème d'hétérogénéité inobservée invariante dans le temps.
* Interprétation: les évolutions expliquent les évolutions.
* LSDV: variables dichotomiques en très grand nombre (quand on les estime) $\Rightarrow$ on n'imprime généralement pas les résultats.
* Disparition de la constante en effets fixes mais pas en différences premières.

* **Disparition de toutes les variables constantes dans le temps** $\Rightarrow$ effet contenu dans les variables dichotomiques individuelles.
    * ex: immigration.
    * Parfois, les variables présumées constantes se maintiennent en raison de points aberrants:
        * incohérence de déclaration d'une vague à l'autre,
        * changement de sexe,
        * diplômes tardifs...
* On peut les introduire malgré tout en les croisant avec une variable temporelle. L'interprétation reste en terme d'évolution.

### Se concentrer sur la variance interindividuelle et éliminer la variance intra-individuelle

**Etudier la variance interindividuelle**

* Le modèle à effets fixes ou *within* permet d'étudier les évolutions intra-individuelles.
* La régression homogène (*pooled*) ou celles à effets aléatoires sont deux manières d'analyser une combinaison de variations intra-individuelles et interindividuelles.
* Peut-on étudier les variations strictement interindividuelles? Oui, de deux façons:
    * Régression toute simple sur une seule période.
    * Régression *between*.
    
#### Régression *between*

Régression où l'on explique la moyenne par individu de la variable expliquée par les moyennes par individu des variables explicatives.
$$\bar y = \beta_0 + \beta_1 \bar x_{1i} + ... + \beta_k \bar x_{ki} + \bar \epsilon_i$$

Cette régression informe sur la variation interindividuelle. Elle peut être considérée comme la bonne régression:

* Si la variation intra-individuelle dans le temps est négligeable,
* Si les individus qui connaissent des variations intra-individuelles sont non représentatifs.


```r
plm(y ~ x1 + x2, index, model = "between", data)
```

### Limites des effets fixes

* On estime les effets sur les individus qui connaissent des évolutions.
    * Si $y_i$ ne change pas en fonction de $t$, alors $y_i$ capturé par l’effet fixe $a_i$.
    * Ces évolutions, surtout sur des variables explicatives qualitatives, peuvent être estimées sur des individus rares et très singuliers : biais de sélection
    * Les variables explicatives du changement peuvent être aussi très singulières
        * Ex extrême: changement de sexe. 
        Cela revient à considérer que la différence de résultats entre les sexes est estimée par l’évolution de résultat pour ceux qui changent de sexe
        * Ex classique: promotion non-cadre $\rightarrow$ cadre
    * Les effets fixes reviennent à considérer que les évolutions estimées sur les gens qui changent sont représentatives des différence d’état entre gens qui changent pas.

* Les effets fixes permettent bien de corriger l’hétérogénéité inobservée! Mais une partie seulement
    * L’hétérogénéité inobservée invariante dans le temps...

* Mais...transforment une régression en une régression en évolution...
    * Où un facteur d’évolution corrélé aux autres peut être inobservé et conduire à biaiser les autres
    * Où il peut y avoir simultanéité des évolutions de la variable indépendante et des variables indépendantes
    * $\Rightarrow$ variables instrumentales (si on en trouve)

* Pas de correction de l’hétérogénéité inobservée qui varie dans le temps…
* Ontologie essentialiste
    * Effet individuel: fonds inchangé, permanent, toujours le même.
* Les évolutions expliquent les évolutions, mais le fixe n'explique pas le changement (sauf spécification contraire).

### Extension logistique

* Probit (effets aléatoires), Logistique (effets fixes, effets aléatoires)^[Logit en panel.]
    * NB: modèles probit déconseillés avec des effets fixes.
* Package `pglm`:
    * binomial models (logit and probit), count models (poisson and negbin) and ordered models (logit and probit).
    * Syntaxe (exemple - actuellement, la méthode *within* et *between* ne fonctionne pas pour les modèles logit et probit avec pglm.)

```r
pglm(y ~ x1 + x2, index, data, family = "binomial", model = "random")
```
    
* Package `survival`:
    * clogit

```r
clogit(y ~ x1 + x2 + strata(var_indiv), data) # je suis pas sûre. de toute façon on n'utilise pas cette méthode.
```
    
