recomdata <- reactive({
  selected_movies <- movie_data %>%
    filter(movieId %in% new_movieId) %>%
    filter(title %in% input$movie_selection) %>%
    arrange(title) %>%
    select(-c(genres))
  
  for(i in 1:nrow(selected_movies)){
    selected_movies$ratingvec[i] <- input[[as.character(selected_movies$title[i])]]
  }
  
  rating_vec <- new_movies %>% left_join(., selected_movies, by = "movieId") %>% 
    pull(ratingvec)
  rating_vec <- as.matrix(t(rating_vec))
  rating_vec <- as(rating_vec, "realRatingMatrix")
  print("Predicting...")
  top_5_prediction <- predict(rec_mod, rating_vec, n = 5)
  print("Finished")
  top_5_list <- as(top_5_prediction, "list")
  print(top_5_list)
  top_5_df <- data.frame(top_5_list)
  print("Dataframed")
  colnames(top_5_df) <- "movieId"
  print(top_5_df)
  top_5_df$movieId <- as.numeric(top_5_df$movieId)
  print(top_5_df)
  names <- left_join(top_5_df, movie_data, by="movieId")
  print(names)
  names <- as.data.frame(names) %>%select(-c(movieId, genres)) %>% 
    rename(Title = title)
  names
})


observeEvent(input$run, {
  
  recomdata <- recomdata()
  
  if(length(input$movie_selection) < 2){
    sendSweetAlert(
      session = session,
      title = "Please select more movies.",
      text = "Rate at least two movies.",
      type = "info")
  } else if(nrow(recomdata) < 1){
    sendSweetAlert(
      session = session,
      title = "Please vary in your ratings.",
      text = "Do not give the same rating for all movies.",
      type = "info")
    
  } else{
    output$recomm <- renderTable(recomdata) 
  }
  
})