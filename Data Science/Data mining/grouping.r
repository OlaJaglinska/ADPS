# Autor: Ola Jaglińska
# GRUPOWANIE

library(factoextra)
library(dbscan)
library(fpc)
library(cluster)
library(mclust)
library(dplyr)

            ### 1. Zapoznanie z danymi. Jakiego typu są atrybuty? Czy są wartości brakujące? ###

download.file('http://staff.ii.pw.edu.pl/~rbembeni/dane/Pokemon.csv','Pokemon.csv')
pokemon <- read.csv("Pokemon.csv")
str(pokemon)
View(pokemon)
summary(pokemon)


table(pokemon$Type.2)
table(pokemon$Type.2, useNA = "ifany")
is.na(pokemon$Type.2)

table(pokemon$Generation)
table(pokemon$Generation, useNA = "ifany")


# Skalowanie statystyk pokemonów

pokemonStats <- pokemon[5:11]
pokemonStats
pokemonStatsScale <- as.data.frame(lapply(pokemonStats, scale))
summary(pokemonStatsScale)
summary(pokemonStats)

                  #### 2. Grupowanie algorytmem partycjonującym #### 

#### a. Metoda "łokcia", aby wyznaczyć liczbę grup
set.seed(12345)
randomPS1 <- sample_n(pokemonStats, 200)
randomPS2 <- sample_n(pokemonStats, 200)
randomPS3 <- sample_n(pokemonStats, 200)
randomPS4 <- sample_n(pokemonStats, 200)

wss <- 0
for (i in 1:15) 
{
  km.out <- kmeans(randomPS1, centers = i, nstart=20)
  wss[i] <- km.out$tot.withinss
}

plot(1:15, wss, type = "b",  xlab = "Liczba grup", ylab = "Suma bledu kwadratowego wewnatrz grup")

wss <- 0
for (i in 1:15) 
{
  km.out <- kmeans(randomPS2, centers = i, nstart=20)
  wss[i] <- km.out$tot.withinss
}

plot(1:15, wss, type = "b",  xlab = "Liczba grup", ylab = "Suma bledu kwadratowego wewnatrz grup")


for (i in 1:15) 
{
  km.out <- kmeans(randomPS3, centers = i, nstart=20)
  wss[i] <- km.out$tot.withinss
}

plot(1:15, wss, type = "b",  xlab = "Liczba grup", ylab = "Suma bledu kwadratowego wewnatrz grup")

wss <- 0
for (i in 1:15) 
{
  km.out <- kmeans(randomPS4, centers = i, nstart=20)
  wss[i] <- km.out$tot.withinss
}

plot(1:15, wss, type = "b",  xlab = "Liczba grup", ylab = "Suma bledu kwadratowego wewnatrz grup")
# Na wykresach widoczne jest lekkie załamanie w punkcie 3.


### b. Grupowanie z różnymi wartościami parametrów

set.seed(2345)
pokemon_kmeans1 <- kmeans(pokemonStatsScale, 3, iter.max =20, nstart = 20)
print(pokemon_kmeans1)

pokemon_kmeans2 <- kmeans(pokemonStatsScale, 3, nstart = 10)
print(pokemon_kmeans2)

pokemon_kmeans3 <- kmeans(pokemonStatsScale, 3, iter.max =100)
print(pokemon_kmeans3)

### c. Ocena jakości grupowa przy użyciu indeksu Silhouette.

kmAlt<-eclust(pokemonStats, "kmeans", k=3, graph=TRUE)
fviz_silhouette(kmAlt, palette="jco")

kmAltScale<-eclust(pokemonStatsScale, "kmeans", k=3, graph=TRUE)
fviz_silhouette(kmAltScale, palette="jco")
# Wynik indeksu Silouette jest wyższy w przypadku wartości nieprzeskalowanych

silinfo<-kmAlt$silinfo
names(silinfo)
silinfo$clus.avg.widths
# Grupa nr 2 miała najwyższy indeks Silhuette = 0.568; gr 1 = 0.382; gr 3 = 0.350

silinfoScale<-kmAltScale$silinfo
names(silinfoScale)
silinfoScale$clus.avg.widths
# Przy wartościach skalowanych te wyniki dla grup 1 i 3 są o połowę niższe.


### d. Przypisanie poszczególnych rekordów do grup. 

# Zastosuję dane bez skalowania, bo dawały lepsze wyniki. Dodam kolumnę z nr grupy do tabeli.

pokemon_clus<-cbind(pokemon, kmAlt$cluster)
head(pokemon_clus)


### e. Znalezienie charakterystycznych elementów grup
# PAM - partitioning around medoids

fviz_nbclust(pokemonStatsScale, pam, method = "silhouette")+theme_classic()
# algorytm sugeruje najlepsze wyniki Silhuette przy podziale na 2 grupy, 
# Zbadam temat jako poboczną ciekawostkę, ale sama analiza wciąż opiera się na grupowaniu na 3 grupy

pamPokemonScale <- pam(pokemonStatsScale, 2)
print(pamPokemonScale)
pamPokemonScale$clustering

fviz_cluster(pamPokemonScale,
             palette = c("#FF6347", "#20B2AA"),
             ellipse.type = "t",
             repel = TRUE,
             ggtheme = theme_light()
)

# Aby porównać oba algorytmy partycjonujące wykonam grupowanie na 3 grupy
pamPokemonScale3 <- pam(pokemonStatsScale, 3)
print(pamPokemonScale3)
pamPokemonScale3$clustering

fviz_cluster(pamPokemonScale3,
             palette = c("#FFD700", "#FF6347", "#20B2AA"),
             ellipse.type = "t",
             repel = TRUE,
             ggtheme = theme_light()
)
# Na wykresie punkty i elipsy grupa nachodzą na siebie. Podział na 2 grupy jest bardziej czytelny, ale problem również występuje. 
# Pokemony w obrębie każdej grupy mają podobne statysyki dotyczące ich możliwości walki, wytrzymałości itd.

# Dla grupowania na 3 grupy elementem charakterystycznym dla grupy 1 -jest ID 396, dla grupy 2 - ID 384, grupy 3 - ID 250

# Wyniki indeksu Silhouette przy metodzie PAM, bez skalowania
pamAlt<-eclust(pokemonStats, "pam", k=2, graph=TRUE)
fviz_silhouette(pamAlt, palette="jco")

pamAlt3<-eclust(pokemonStats, "pam", k=3, graph=TRUE)
fviz_silhouette(pamAlt3, palette="jco")

# W przypadku podziału na 3 grupy indeksy Silhouette poszczególnych grup są niższe niż przy grupowaniu kmeans. 
# W tym wypadku metoda kmeans daje lepsze wyniki podziału na 3 grupy niż algorytm pam.


        ### 3. Grupowanie algorytmem DBSCAN ###
### a. Wyznaczenie parametru eps dla algorytmu DBSCAN metodą szukania punktu przegięcia
#z wykorzystaniem 25% losowo wybranych danych – sprawdzenie dla kilku wartości K
set.seed(12345)
randomPS <- sample_n(pokemonStatsScale, 200)

dbscan::kNNdistplot(randomPS, k=4)
abline(h=1.5, lty="dashed")

dbscan::kNNdistplot(randomPS, k=5)
abline(h=1.5, lty="dashed")

dbscan::kNNdistplot(randomPS, k=6)
abline(h=1.5, lty="dashed")

dbscan::kNNdistplot(randomPS, k=7)
abline(h=1.55, lty="dashed")

# W większości przypadków punkt przygięcia jest około wartości 1.5 to będzie nasz maksymalny promień sąsiedztwa Eps

### b. Wykonanie grupowania dla kilku zestawów wartości parametrów.

pokemon.dbscan_2 <- dbscan::dbscan(pokemonStatsScale, eps=1.5, minPts=2)
print(pokemon.dbscan_2)

pokemon.dbscan_3 <- dbscan::dbscan(pokemonStatsScale, eps=1.5, minPts=3)
print(pokemon.dbscan_3)

pokemon.dbscan_4 <- dbscan::dbscan(pokemonStatsScale, eps=1.5, minPts=4)
print(pokemon.dbscan_4)

pokemon.dbscan_5 <- dbscan::dbscan(pokemonStatsScale, eps=1.5, minPts=5)
print(pokemon.dbscan_5)

# Przy powyższych parametrach wartość minPts=3 skutkuje podziałem na 3 grupy, z 38 punktami szumu, 
# przy wyższych minPts jest więcej szumu, a minPts = 2 daje podział na 5 grup

plot(pokemon.dbscan_3, pokemonStatsScale[c(1,2)])
plotcluster(pokemonStatsScale,pokemon.dbscan_3$cluster)

### c. Ocena jakości grupowa przy użyciu indeksu Silhouette.

pokemon.dbscam_3Sil <- cluster.stats(dist(pokemonStatsScale), pokemon.dbscan_3$cluster)
pokemon.dbscam_3Sil$clus.avg.silwidths
pokemon.dbscam_3Sil$avg.silwidth

# Indeks Silhouette dla całego grupowania = 0.259. 
# Dla poszczególnych grup -> 0 (szumy): -0.1819022,  1 (najliczniejsza): 0.2770858,  3: 0.5996486,  4: 0.6684093
# Grupowanie za pomocą dbscan wypadło gorzej niż kmeans

### d. Przypisanie poszczególnych rekordów do grup
pokemon_clus1<-cbind(pokemon_clus, pokemon.dbscan_3$cluster)
head(pokemon_clus1)


      ### 4. Porównanie wyników uzyskanych dwoma metodami grupowania ###

km<-kmeans(pokemonStatsScale,3)
cs_km<-cluster.stats(dist(pokemonStatsScale), km$cluster)
cs[c("within.cluster.ss","avg.silwidth")]

dbs <- dbscan::dbscan(pokemonStatsScale, eps=1.5, minPts=3)


sapply(list(kmeans<-km$cluster, dbscan<-dbs$cluster), 
       function(c) cluster.stats(dist(pokemonStatsScale),c)[c("within.cluster.ss","avg.silwidth")])


#                   [,1]      [,2]     
#within.cluster.ss 3033.315  5235.781 
#avg.silwidth      0.2501699 0.2589392

# Z moich obliczeń wynika, że zastosowany algorytm partycjonujący k-średnich (kmeans) ma lepsze parametry grupowania niż 
# algorytm gęstościowy dbscan. Wnioskuję to na podstawie dużo niższej sumy kwadratów. 
# W indeksie Silouette algorytm dbscan ma minimalną różnicę na plus.


# Co by było gdyby nie skalowanie?

km2<-kmeans(pokemonStats,3)

dbs2 <- dbscan::dbscan(pokemonStats, eps=50, minPts=3)

sapply(list(kmeans<-km2$cluster, dbscan<-dbs2$cluster), 
       function(c) cluster.stats(dist(pokemonStats),c)[c("within.cluster.ss","avg.silwidth")])

# Przy zastosowaniu danych nieskalowanych algorytm dbskan kompletnie sobie nie poradził. 
# W kolumnie "Total" mamy zsumowane pozostałe parametry i są to kilkukrotnie wyższe wartości.
# Gdyby wyeliminować tę kolumnę, być może grupowanie mogłoby mieć sens, również bez skalowania.

