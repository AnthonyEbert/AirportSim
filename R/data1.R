

#' Global
#' @name Global
#' @aliases Global_fun
#' @aliases Global_list
#' @title Global
#'
#' @rdname Global
#' @export
global_fun_1 <- function(
  distance_dpl   = 100,
  distance_imm   = 150,
  distance_bh    = 80,
  mu             = 0.02,
  vm2            = 0.64,
  lag            = 0.005,
  rate_bags      = 4,
  nu_bags        = 1.2,
  server_bags    = 8,
  server_cus     = 10,
  rate_cus       = 3
){

  return(as.list(environment(), all=TRUE))
}

global_level_1 <- global_fun_1()

#' Generate FlightSchedule
#' @export
generate_flightlevel <- function(n, max_time = 1000){
  output <- tibble::tibble(
    arrive        = runif(n, 0, max_time),
    gate          = sample(1:5, n, replace = TRUE),
    passengers    = sample(50:700, n, replace = TRUE),
    scale_dpl     = runif(n, 2, 4),
    shape_dpl     = runif(n, 2, 3)
  )

  p_nat <- as.list(as.data.frame(t(dplyr::data_frame(x = runif(n, 0, 1), y = 1-x))))
  names(p_nat) <- NULL

  output$p_nat <- p_nat

  output <- output %>%
    arrange(arrive) %>%
    mutate(flight = paste0("flight ", 1:n)) %>%
    select(
      flight, arrive, gate, passengers, scale_dpl, shape_dpl, p_nat
    )

  return(output)
}

flight_level_1 <-
  tibble::tribble(
    ~flight    , ~arrive, ~gate , ~passengers, ~scale_dpl, ~shape_dpl, ~p_nat     ,
    "flight 1" , 10     , 1     , 150        , 4.2       , 3.7       , c(0.2, 0.8),
    "flight 2" , 30     , 2     , 200        , 2.8       , 2.0       , c(0.5, 0.5),
    "flight 3" , 50     , 3     , 200        , 4.2       , 3.3       , c(0.5, 0.5),
    "flight 4" , 65     , 2     , 250        , 3.1       , 2.1       , c(0.3, 0.7),
    "flight 5" , 72     , 4     , 250        , 4.0       , 2.1       , c(0.9, 0.1),
    "flight 6" , 80     , 2     , 180        , 3.4       , 2.6       , c(0.9, 0.1),
    "flight 7" , 85     , 1     , 470        , 3.0       , 2.8       , c(0.4, 0.6),
    "flight 8" , 100    , 3     , 620        , 3.4       , 2.7       , c(0.1, 0.9),
    "flight 9" , 118    , 4     , 300        , 2.2       , 2.4       , c(0.5, 0.5),
    "flight 10", 120    , 2     , 310        , 3.3       , 2.7       , c(0.3, 0.7)
  )

gate_level_1 <-
  tibble::tribble(
    ~gate, ~distance_gate, ~lag_bags, ~handler ,
    1    ,  80           ,  5       , "team A" ,
    2    ,  30           , 15       , "team A" ,
    3    , 300           ,  5       , "team B" ,
    4    , 450           ,  5       , "team B" ,
    5    , 800           , 10       , "team B"
  )

nat_level_1 <-
  tibble::tribble(
    ~nat      , ~rate_imm, ~server_imm                              ,
    "foreign" , 1.2      , as.server.stepfun(c(0, 100), c(0, 12, 9)),
    "local"   , 1.6      , 15
  )


#' Airport_1
#' @name Airport_1
#' @aliases airport_fun_1
#' @aliases airport_list_1
#' @title Airport spreadsheet
#'
#' @rdname Airport_1
#' @export
airport_fun_1 <- function(
  global_level      = as.data.frame(global_level_1),
  flight_level      = flight_level_1,
  gate_level        = gate_level_1,
  nat_level         = nat_level_1
){

  return(as.list(environment(), all=TRUE))
}
#'
#' @rdname Airport_1
#' @export
airport_list_1 <- airport_fun_1()
