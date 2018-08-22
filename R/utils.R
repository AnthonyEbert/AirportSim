


#' @export
Resources_df <- function(input){

  input <- input %>% arrange(time)

  create_server_list <- function(df){
    output_df <- data.frame(server = list(1))

    if(dim(df)[1] == 1 | is.null(dim(df)[1])){
      server <- df$server
    } else {
      server <- queuecomputer::as.server.stepfun(df$time[-1], df$server)
    }

    output_df$server[1] <- list(server)
    output_df$server <- as.list(output_df$server)

    output_df$X1 <- NULL

    return(output_df)

  }

  output <- input %>%
    group_by(section, route) %>%
    do(create_server_list(.)) %>%
    ungroup()

  return(output)

}





