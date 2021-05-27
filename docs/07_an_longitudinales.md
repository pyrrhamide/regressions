# Analyses longitudinales {#an-long}




```r
library(plm)

library(survival)
library(survminer)
```

## Pseudo-panels

## Modèles linéaires

Modèle de base:
$$y_{i,t} = \alpha_i + \beta_i k_{i,t} + \gamma_i n_{i,t} + \epsilon_{i,t}$$

```r
lineaire <- lm(y ~ x1 + X2, data=d)
```

Modèle pooled^[Moindres Carrés Ordinaires askip???]:
$$y_{i,t} = \alpha + \beta k_{i,t} + \gamma n_{i,t} + \epsilon_{i,t}$$

```r
pooled <- plm(y ~ x1 + X2,
              data = d,
              index = c("var_individu","var_temporelle"),
              model = "pooling")
```

Modèle à effet fixe:
$$y_{i,t} = \alpha_i + \beta k_{i,t} + \gamma n_{i,t} + \epsilon_{i,t}$$

```r
effet_fixe <- plm(y ~ x1 + x2,
                  data,
                  index,
                  model = "within")

# twoways: estimer l'effet fixe individuelle et l'effet fixe temporel
model_sete <- plm(y ~ x1 + x2,
                  data,
                  index,
                  model = "within",
                  effect = "twoways")
```

Tests

```r
## Test de Fischer ##
# Test sur la pertinence de l'hypothèse de l'existence d'un effet fixe individuel (s'applique aussi au modèle pooled). Seule la p-value nous intéresse.
coeftest(effet_fixe, vcov. = vcovHC, type = "HC1")

## pFtest: F-test pour comparer le pouvoir explicatif du modèle A par rapport au modèle B ##
pFtest(effet_fixe, pooled)

## Test de Hausman ##
phtest(effet_fixe, pooled)
```

## Modèles dynamiques


```r
plm(y ~ lag(y) + lag(X1) + x2,
    data,
    index,
    model = "within", # ou autre
    effect = "individual") # ou autre
```

## Modèles non-linéaires

## Modèles de durée

## Optimal matching
