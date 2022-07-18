# Autor: Ola Jaglińska

# Cel: Odkrycie częstych reguł asocjacyjnych na zbiorze produktów spożywczych Groceries. Jakie produkty były kupowane razem? 
# Z jakim prawdopodobieństwem klient który zakupił produkt A kupi również produkt B?
# Odkryte reguły moga zostać wykorzystane do zwiększenia skuteczności działalności marketingowej np. reklamy, oferty personalizowane, sugerowane produkty ("inni klienci zakupili również...").
# Dla sklepu może to być również ważna informacja przy doborze asortymentu.
# Reguła interesująca będzie miała współczynnik podniesienia(lift) > 1 oznaczający zależność pozytywną jej elementów oraz będzie przekraczała zadane minimalne wsparcie i minimalne zaufanie.
# Minimalne parametry wsparcia i zaufania ustalę przy wstępnym zapoznaniu się z danymi. 
# Będę poszukiwała możliwie dużego wsparcia, przy zbiorze niespełna 10tys elementów, wsparcie już na poziomie kilku procent już może być interesujące.
# Najlepszą regułą będzie ta o możliwie największym wsparciu.


library(arules)
library(arulesViz)

data("Groceries")
dim (Groceries)
summary(Groceries)
inspect(Groceries[1:5])
View(Groceries@itemInfo)

# Zbiór miał już postać transakcyjną, niezbędną do analiz z użyciem biblioteki arules.
# Najczęściej znajdowanymi elementami w zbiorze są: whole milk, other vegetables, rolls/buns, soda, yogurt, bottled water
# Transakcje średnio miały 4,409 produktów. Zakupu tylko jednego produktu dokonano w 2159 transakcjach, największa transakcja zawierała 32 produkty.

# częstość występowania elementów
itemFrequencyPlot(Groceries, support = 0.1)
itemFrequencyPlot(Groceries, topN = 10, main = "10 najczęściej występujących elementów")

freqGro = itemFrequency(Groceries, type = "relative")
print(freqGro[freqGro>0.15])
length(freqGro[freqGro>=0.05])
# 28 elementów występuje w 5% lub większej ilości transakcji. Whole milk, other vegetables, rols/buns, soda występują w więcej niż 15% transakcji.

sup = seq(0.01,0.21,0.02)
nbFSet <-vector(mode = 'integer', length = length(sup))
for(i in 1:length(sup))
{
  nbFSet[i] = length(freqGro[freqGro >= sup[i]])
}
resGro <- data.frame(sup, nbFSet)
View(resGro)


aParam  = new("APparameter", "confidence" = 0.38, "support" =0.01, "minlen"= 2)
aprioriGro <- apriori(Groceries,aParam)
summary(aprioriGro)
size(aprioriGro)
length(aprioriGro)

inspect(head(sort(aprioriGro, by="support"), 10))

# wykrywanie zbiorów częstych przy pomocy algorytmu Eclat
ecParam  = new("ECparameter", "support" = 0.006) 
eclatGro <- eclat(Groceries,ecParam)
summary(eclatGro)
size(eclatGro)
length(eclatGro)
inspect(head(sort(eclatGro, by="support"), 10))

# Algorytm Eclat wykrywa dużo więcej reguł przy tym samym wsparciu. Prawdopodobnie jest to spowodowane mniejszą ilością parametrów. 
# Przy Apriori ustawiłam zaufanie(confidence) na poziomie 0.38, ponieważ przy tym zaufaniu wykryta jest reguła o najwyższym możliwym wsparciu tj 7,4%. 
# Przy ustawionych parametrach Apriori lift dla wykrytych reguł jest większy od 1 tj. mam pewność, że zależność jest pozytywna. 
# W Apriori zmiany parametru wsparcia(support) regulują jedynie ilość wykrywanych reguł. Przy ustawieniu kolejności reguł od najwyższego wsparcia początek listy reguł jest ten sam.
# Pozostaję przy tworzeniu reguł na podstawie zbiorów częstych algorytmu Apriori

rule_data <- DATAFRAME(aprioriGro, 
                       separate = TRUE, 
                       setStart = '', 
                       itemSep = ',', 
                       setEnd = '')

View(rule_data)
inspect(head(aprioriGro))
inspectDT(head(aprioriGro,100))


resTbl <- interestMeasure(aprioriGro,"improvement")
intres <- which(sapply(resTbl, function(x) {x > 0.01  && x <= 1 })==TRUE)

intersRule <- aprioriGro[intres] 
inspect(head(sort(intersRule, by="support"), 10))

# Dla podanych parametrów najczęściej występującą regułą jest {other vegetables} => {whole milk}: 
# - w 7,5% wszystkich transakcji w zbiorze Groceries (736 transakcjach) klient, który kupił other vegetables, kupił również whole milk
# - jeżeli kupiono other vegetables to jest 39% szans na zakup whole milk



# W pierwszej dziesiątce reguł z najwyższym wsparciem przy zadanych parametrach znalazły się również tropical fruit.
# Owoce tropikalne mogą być mniej popularne niż nabiał, pieczywo, jogurty lub warzywa korzeniowe, które są podstawowymi produktami.
# Reguły związane z tropical fruit mogą być interesujące. Zakładając, że są nieco to droższe produkty może warto byłoby je spopularyzować wśród odbiorców?

tropicalGro <- subset(aprioriGro, subset = items %pin% "tropical")
inspect(head(sort(tropicalGro, by="support"),10))
summary(tropicalGro)

plot(tropicalGro, measure = c("support", "lift"), shading = "confidence")


# Wykrycie reguł gdzie następnikiem jest tropical fruit
rulesWithRHS <- apriori(Groceries, parameter = list(support=0.006, confidence = 0.26, minlen = 2), 
                        appearance = list(rhs = c("tropical fruit")))
inspect(sort(rulesWithRHS, by="support"))
summary(rulesWithRHS)

# tropical fruit występuje w 50 regułach, w 17 z nich jest następnikiem


# WNIOSKI
# Moje wyniki poprawiłoby zastosowanie agregacji lub wykorzystanie hierarhii, nie zdążyłam zgłębić tematu.
# Ustawienie minimalnej ilości elementów w regule na 2 pozwoliło na lift większy od 1
# Najwyższe wsparcie reguły z następnikiem tropical fruit wyniosło 2% (poprzednikiem był pip fruit). Osoba, która kupuje owoce pestkowe będzie skłonna kupić również owoce tropikalne.
# Maksymalne wsparcie reguły na calym zbiorze, bez hierarchizacji wyniosło 7,5%