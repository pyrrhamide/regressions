# (PART\*) Autres méthodes {-}



# Analyses de réseaux {#an-res}


```r
library(igraph)

graph <- graph.data.frame(links,nodes,directed=TRUE)
graph <- graph.adjacency(df,mode="directed")
```

## Bases de la théorie
- **Graphe** : ensemble d'unités (sommets) connectées par une ou plusieurs relations (arêtes)
  - Sommets (noeuds, *vertices*) : unités
  - Arêtes (liens, *edges*) : relations
- Réseaux *complets* v réseaux *personnels* (réseaux **égo-centrés**)


```r
# Taille du réseau = nombre de noeuds
length(V(graph))

# Nombre de liens
length(E(graph))
```

### Matrices
Ou comment stocker ses données avant de les traiter.

- d'adjacence
  - matrice symétrique avec liens non-orientés (du coup liens réciproques)
- Carrée $n* n$
- *Edge list* : chaque paire de noeuds connectés sur une ligne d'une table
- *Node list* : chaque ligne représente les liens d'un noeud vers tous les autres

### Liens
- Orientés
  - Réciproques
- Non-orientés

## Structures locales
Ou comment un réseau s'organise.

- Noeuds isolés
- Dyades
  - Réciprocité
- Triades (liens orientés)
  - Empty
  - One-edge
  - Two-path
  - Triangle
- Triades (liens non-orientés)
  - Intransitive : liens bilatéraux uniquement
  - Transitive : l'ami de mon ami est mon ami
  - Trois-cycles : forme d'échange généralisé
- Clique : sous-ensemble de noeuds où toutes les paires de noeuds existants sont connectés.
  - *Modularité* : mesure segmentation d'un réseau en *modules*. Réseau à modularité élevée a densité élevée entre les noeuds qui font partie d'un même module, densité faible entre noeuds appartenant à modules différents.


```r
# Trois algorithmes de modularité
wtc <- walktrap.community(graph)
grd <- fastgreedy.community(graph) # fonctionne uniquement pour liens non-orientés
spn <- spinglass.community(graph) # fonctionne si tous les noeuds sont connectés (aucun noeud isolé)

# Indicateur de modularité pour le réseau
modularity(graph, membership(wtc))
modularity(graph, membership(grd))
modularity(graph, membership(spn))
```

## Connectivité
- **Chaîne**/*walk* : parcours sur graphe non orienté allant d'un noeud à un autre en empruntant des arêtes (liens)
- **Chemin** : chaîne mais pour un **graphe orienté**
- Chaîne/chemin **élémentaire** (*path*) si chaque noeud y apparaît au plus une fois.
- **Géodésique** (*geodesic*) : chaîne/chemin élémentaire la/le plus court(e) (*shortest path*) entre deux noeuds.
- **Cycle** : départ et arrivée de la chaîne/chemin élémentaire est le même noeud.
- Graphe **connexe** (*connected*) : chemin ou chaîne entre toute paire de noeuds.
  - **Composante** : sous-graphe maximalement connecté.
- **Distance (géodésique)** : nb de pas (plus courts chemins) entre un noeud et l'autre.
  - noeuds connectés ont distance 1
  - noeuds dans composantes différentes ont distance infinie
- **Diamètre** : distance la plus longue entre deux noeuds.
- **Average path length** : distance moyenne entre toutes les pairs de noeuds dans un réseau (moins sensible à des outliers que le diamètre).
- **Eccentricité** : distance depuis un noeud de départ vers le noeud le plus loin dans le réseau.
- **Rayon** : eccentricité minimale des noeuds. La plus petite distance à laquelle puisse se trouver un noeud de tous les autres (infini si graphe est non connecté)


```r
shortest.paths(graph, algorithm="unweighted")

# Shortest path entre deux noeuds
get.shortest.paths(graph,
                   V(graph)[name=="name1"],
                   V(graph)[name=="name2"],
                   mode="all", output="both")

# Distance moyenne entre les noeuds
average.path.length(graph)

# Diamètre
diameter(graph)

# Eccentricité
eccentricity(graph)

# Rayon : eccentricité la plus faible
radius(graph)
```

## Mesures basiques de cohésion
Tous les noeuds sont-ils liés entre eux? Quels types de liens existent dans le réseau et dans quelle quantité?

- **Transitivité** : $\frac{nombre.triades.transitives}{nombre.triades}$
  - *égal à 1 si tous les noeuds sont liés à tous les autres noeuds* (connectivité complète)
  - Excède rarement 0.2 dans réseaux aléatoires.
  - Souvent compris entre 0.3 et 0.6 dans les réseaux empiriques.
- **Densité** : $\frac{nombre.liens.existants}{nb.liens.pouvant.existés}$
  - $\frac{L}{(n*(n-1))}$ liens orientés
  - $\frac{L}{\frac{(n*(n-1))}{2}}$ liens non-orientés
- **Coefficient de *clustering* ** : mesure de cohésion dans le voisinage d'un noeud (combien de mes amis sont amis entre eux). 2 mesures :
  - Mesure *locale* : on mesure d'abord pour chaque noeud *i*, le $Cl_{i}$ ensuite on prend la moyenne $\sum_{i = 1}^{n}$$\frac{Cl_{i}}{n}$. Tends to 1.
  - Mesure *globale* : $\sum_{i=1}^{n}$$\frac{nombre.liens.existants.entre.amis.de.i}{nombre.liens.possibles.entre.amis.de.i}$. Tends to 0 => transitivité.


```r
# Transitivité du réseau
transitivity(graph)

# Transitivité d'un noeud
transitivity(graph,type="local")

# Densité du réseau
graph.density(graph)

# Nombre d'îles, i.e. clusters
clusters(graph)
```

## Mesures de diversité
Tous mes groupes sont-ils représentés proportionnellement dans mon réseau?

- Deux familles de mesures:
  - proportion (ou pourcentage) d'une catégorie sur la totalité
  - hétérogénéité (variance, écart-type, IQV...)
- **Indice de diversité de Blau** $\in[0;\frac{k-1}{k}]$ Une seule catégorie représentée => toutes les catégories représentées équitablement (utile si plus de 2 catégories - variante de l'indice Herfindahl-Hirschmann (HHI))
- **Indice de variation qualitative, IQV** $\in[0;1]$ Une seule catégorie représentée => toutes les catégories représentées équitablement (**un indice POUR CHAQUE ATTRIBUT d'intérêt**)


```r
get.Blau.index <- function(x, type) {
  x <- factor(x, levels = type);
  return(1 - sum(prop.table(table(x))^2))}

# Indice de diversité de Blau
qualif_blau <- get.Blau.index(as.factor(V(graph)$variable))
  # on applique la fonction de l'IB à la variable x
qualif_blau

# Indice de variation qualitative
qualif_iqv = qualif_blau / (1 - (1 / length(levels(as.factor(Proportions$Var1)))))
qualif_iqv
  # IQV de Qualification!!!

# HHI qui est égal à 1 - qualif_blau
qualif_hhi <- 1 - qualif_blau
qualif_hhi
```

## Mesures de centralité
Y a-t-il un noeud ou groupe de noeuds qui a une plus grande importance/qui est le plus relié dans le réseau?

- Centralité de **degré** (*degree*)
  - noeuds les plus "actifs" (les plus connectées, qui sont liés à un plus grand nombre de noeuds) $C_D(i) =$ $\sum_{j=1}^{n}x_{ij} = \sum_{j=1}^{n} x_{ji}$
    - mesure normalisée: $C'_D(i)=\frac{\sum_{j=1}^{n}x_{ij}}{n-1}$
  - centralité de *demi-degré* pour graphe orienté. Indicateur de position sociale.
    - Extérieur (*outdegree*) = nb liens sortants (e.g: demander beaucoup de conseils)
    - Intérieur (*indegree*) = nb liens entrants (e.g: recevoir beaucoup de demandes de conseils)
- Centralité d'**intermédiarité** (*betweenness*)
  - position stratégique, entre différentes parties du réseau (e.g être le lien entre deux parties non connectées)
  - nb de plus courts chemins entre toute paire d'acteurs *k* et *j*, et on prend ceux qui passent par *i*
  - $C_B(i)=$$\sum_{jk}$$\frac{s_{kij}}{s_{kj}}$
- Centralité de **proximité** (*closeness*). Un peu comme centralité de **degré**, mais noeuds sont pas aussi centraux.
- Centralité de **vecteur propre** (*eigenvector*). Être connecté aux autres noeuds les plus connectés.

- Centralité dans un réseau : se calcule pour chaque noeud dans un réseau (devient un attribut du noeud) [NB: soit centra de proxi, soit centra de degré, soit intermédiarité, etc...]. Dans quelle mesure le réseau est dominé par un noeud central (ou peu de noeuds centraux) ? On compare la centralité du noeud le plus central à la centralité des autres noeuds. Au niveau du réseau dans son ensemble, on peut regarder:
  - La **distribution des centralités** des noeuds;
  - Des indicateurs de "centralisation" agrégés.
    - mesure de centralisation de Freeman


```r
# Centralité de degré
degree(graph,mode="all")
degree(graph,mode="in")
degree(graph,mode="out")

# Centralité d'intermédiarité
betweenness(graph,directed=TRUE)

# Centralité de proximité
# il faut d'abord enlever les noeuds isolés, sinon le calcul ne marche pas
Isolated = which(degree(graph)==0)
graph2 = delete.vertices(graph, Isolated) # on construit un nouveau graphe en enlevant Isolated

  # on calcule la proximité sur ce graphe
close_graph <- closeness(graph2, mode='all', normalized = FALSE)
# pour obtenir la valeur normalisée, la commande est :
close_graph2 <- closeness(graph2, mode='all', normalized = TRUE)

# Centralité de vecteur propre
eigen_centrality(graph, scale = TRUE, weights = NULL)
```
