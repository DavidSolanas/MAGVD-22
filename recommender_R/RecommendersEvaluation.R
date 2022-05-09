library(recommenderlab)
library(dplyr)

rm(list=ls())

#El objeto que utiliza recommenderlab para entrenar los modelos son matrices 
#usuario-ítem que pueden ser de tipo realRatingMatrix o binaryRatingMatrix

#Esto se puede realizar a partir de una matriz ya creada o a partir de un 
#data.frame con las con 3 columnas en orden: user | item | rating

df <- read.csv("../../db_export/ratings_reduced.csv")

head(df)

#Para crear el objeto de clase realRatingMatrix se utiliza la función as.
ui <- df %>% as("realRatingMatrix")
ui[1:10,1:10] %>% getRatingMatrix

#Una matriz realRatingMatrix se puede parsear tanto a matrix, data.frame o list.
ui %>% as("matrix") %>% .[1:10,1:10]
ui %>% as("data.frame") %>% head

# Binarizar la matriz
ui_bin <- ui %>% binarize(minRating = 4)
ui_bin[1:10,1:10] %>% as("matrix")

#Las matrices realRatingMatrix aceptan operaciones matriciales como rowSums, rowMeans, dim, indexar, etc.

#Por ejemplo,a continuación se muestra el rating promedio de la primera película:
colMeans(ui[,1])

#La función normalize permite normalizar con los métodos “center” y “Z-score” tanto filas como columnas (row = FALSE).
ui %>% getRatings %>% hist(main = "Ratings")
ui %>% normalize %>% getRatings %>% hist(main = "Rating normalizados por usuario")

################################################################################
# Recomendador de popularidad
################################################################################

#Para ejemplificar crearemos un recomendador de popularidad utilizando los 
#usuarios y predeciremos el top 5 para los 2 primeros usuarios.
rec_pop <- Recommender(ui, "POPULAR")
pred_pop <- predict(rec_pop, ui[1:2], type = "topNList", n = 5)

#Para entrenar un modelo, siempre se utiliza la función Recommender, se le 
#entrega la data de entrenamiento y el tipo de modelo a utilizar. Para ver el 
#listado de modelos y parámetros se pueden consultar con recommenderRegistry$grep_entries().

#La función predict funciona como con cualquier otro modelo, pero además se le 
#debe decir qué retornar (“topNList” o “ratings”). En caso de retornar topNList 
#se requiere ingresar el número n.

#Para ver los resultados, se puede desplegar una lista como a continuación:
pred_pop %>% as("list")

################################################################################
# Evaluación de algoritmos según rating
################################################################################

# Obtener data de train y test
# Mínimo de ratings por usuario
rowCounts(ui) %>% as("matrix") %>% min
# Mínimo de ratings por película
colCounts(ui) %>% as("matrix") %>% min

ui <- ui[,colCounts(ui)>= 20]
ui <- ui[rowCounts(ui)>= 20,]

#Debido a que se predicen ratings de ítems en base a ratings sobre otros ítems 
#que haya realizado el usuario, se debe asumir como “conocidos” solo una parte de 
#los ratings. Esto está dado por el parámetro given. 
#(En caso de que given sea negativo, representa “todos menos n”)
eval_scheme <- evaluationScheme(ui, method = "split", train = 0.9, given = 20)
train <- eval_scheme %>% getData("train")
known <- eval_scheme %>% getData("known")
unknown <- eval_scheme %>% getData("unknown")

# Entrenar modelos
r1 <- Recommender(train, "RANDOM")
r2 <- Recommender(train, "UBCF")
r3 <- Recommender(train, "IBCF")
r4 <- Recommender(train, "SVD")
r5 <- Recommender(train, "ALS")
r6 <- Recommender(train, "ALS_implicit")
r7 <- Recommender(train, "RERECOMMEND")
r8 <- Recommender(train, "POPULAR")

# Predecir
p1 <- predict(r1, known, type = "ratings")
p2 <- predict(r2, known, type = "ratings")
p3 <- predict(r3, known, type = "ratings")
p4 <- predict(r4, known, type = "ratings")
p5 <- predict(r5, known, type = "ratings")
p6 <- predict(r6, known, type = "ratings")
p7 <- predict(r7, known, type = "ratings")
p8 <- predict(r8, known, type = "ratings")

# Cálculo del error
error <- rbind("random" = calcPredictionAccuracy(p1, unknown),
               "ubcf" = calcPredictionAccuracy(p2, unknown),
               "ibcf" = calcPredictionAccuracy(p3, unknown),
               "svd" = calcPredictionAccuracy(p4, unknown),
               "als" = calcPredictionAccuracy(p5, unknown),
               "als_implicit" = calcPredictionAccuracy(p6, unknown),
               "rerecommend" = calcPredictionAccuracy(p7, unknown),
               "popular" = calcPredictionAccuracy(p8, unknown)
               )
error

################################################################################
# Evaluación de algoritmos según topN
################################################################################

eval_scheme <- evaluationScheme(ui, method = "cross-validation", k = 10, given = 5, goodRating = 0)

algos <- list("random" = list(name = "RANDOM", param = NULL),
              "UBCF_20nn" = list(name = "UBCF", param = list(nn = 20)),
              "UBCF_50nn" = list(name = "UBCF", param = list(nn = 50)),
              "IBCF_Pearson" = list(name = "IBCF", param = list(method = "Pearson")),
              "IBCF_Tanimoto" = list(name = "IBCF", param = list(method = "Tanimoto")),
              "SVD" = list(name = "SVD"),
              "ALS" = list(name = "ALS"),
              "ALS_implicit" = list(name = "ALS_implicit"),
              "ALS_5" = list(name = "ALS", param = list(n_factors = 5)),
              "POPULAR" = list(name = "POPULAR", param = NULL),
              "RERECOMMEND" = list(name = "RERECOMMEND", param = NULL))

# Evaluar algoritmos
# Se evaluarán los algoritmos para n = 1,3,5,10,15,20. La función eval entrena 
#los algoritmos, predice y entrega la evaluación para todos los algoritmos.

n_recommendations <- c(1, 5, seq(10, 100, 10))

eval <- evaluate(eval_scheme, algos, type = "topNList", n = n_recommendations)
plot(eval)
plot(eval,"prec/rec")

getConfusionMatrix(eval[["ALS_implicit"]])
getConfusionMatrix(eval[["POPULAR"]])





