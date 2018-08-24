









#' @export
post_process_1 <- function(Passenger_df){

  x_obs = Passenger_df$arrive_imm
  y_obs = Passenger_df$depart_imm
  x_obs_f = Passenger_df %>% filter(nat == "foreign") %>% .[["arrive_imm"]]
  x_obs_l = Passenger_df %>% filter(nat == "local"  ) %>% .[["arrive_imm"]]
  y_obs_f = Passenger_df %>% filter(nat == "foreign") %>% .[["depart_imm"]]
  y_obs_l = Passenger_df %>% filter(nat == "local"  ) %>% .[["depart_imm"]]

  return(list(x_obs = x_obs, y_obs = y_obs, y_obs_f = y_obs_f, y_obs_l = y_obs_l, x_obs_f = x_obs_f, x_obs_l = x_obs_l))
}


#' Convert timestamps to binned data
#' @param x object returned by airport_simulate()
#' @param breaks break points of histogram
#' @export
convert_stamps_to_hist <- function(x, breaks, ...){

  out <- lapply(x, safe_hist, breaks = breaks, plot = FALSE, ...) %>%
    as.data.frame() %>%
    mutate(t = breaks[-length(breaks)]) %>%
    tidyr::gather(key, y, -t) %>%
    select(key, t, y) %>%
    mutate(key = factor(key))

  return(out)
}

#' Histogram without error message for data points outside range
#' @param breaks break points
#' @export
safe_hist <- function(breaks, ...){

  stopifnot(is.numeric(breaks))

  x <- hist(breaks = c(-Inf, breaks, Inf), ...)$counts
  x <- x[-c(1, length(x))]
  return(x)
}
