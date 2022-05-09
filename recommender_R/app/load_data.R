movie_data <- read.csv("movies_reduced.csv")
ratings_data <- read.csv("ratings_reduced.csv")

new_movieId <- ratings_data %>% group_by(movieId) %>% 
  summarise(count = n()) %>% 
  dplyr::filter(count > 50) %>%
  pull(movieId)

new_movies <- movie_data %>% dplyr::filter(movieId %in% new_movieId)

movie_names <- movie_data %>% 
  dplyr::filter(movieId %in% new_movieId) %>% pull(title) %>%
  as.character() %>% sort()

ratings_data <- ratings_data %>% dplyr::filter(movieId %in% new_movieId)
rating_mat <- dcast(ratings_data, userId ~ movieId, value.var = "rating", 
                    na.rm=FALSE)
rating_mat <- as.matrix(rating_mat[,-1]) 
rating_mat <- as(rating_mat, "realRatingMatrix")

rec_mod <- Recommender(rating_mat, "ALS_implicit")