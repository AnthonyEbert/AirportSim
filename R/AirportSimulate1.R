
#' @import dplyr
#' @import queuecomputer
#' @export
AirportSimulate1 <-
  function(
    global_level,
    flight_level,
    gate_level,
    nat_level
  ){

    if(is.data.frame(global_level)){
      global_level <- as.list(global_level)
    }

    for(i in 1:length(global_level)){
      assign(names(global_level)[i], global_level[[i]])
    }

  passenger_table <- flight_level %>%
    left_join(data_frame(flight = rep(.$flight, times = .$passengers)), by = "flight") %>%
    mutate(ID = c(1:n())) %>%
    left_join(gate_level, by = "gate")

  passenger_table <- passenger_table %>%
    group_by(flight) %>%
    mutate(nat = sample(nat_level$nat, size = n(), replace = TRUE, prob = p_nat[[1]])) %>%
    left_join(nat_level, by = "nat")

  passenger_table <- passenger_table %>%
    group_by(flight, nat) %>%
    mutate(
      walk_speed   = 1/(rgamma(n(), shape = 1/vm2[1], scale = mu[1] * vm2[1]) + lag[1]),
      deplane      = rgamma(n(), shape = shape_dpl[1], scale = scale_dpl[1]),
      arrive_ac    = arrive + deplane,
      walk_ac      = distance_gate[1] / walk_speed,
      arrive_imm   = arrive_ac + walk_ac,
      service_imm  = rexp(n(), rate_imm[1])
    ) %>%
    group_by(nat) %>%
    mutate(
      depart_imm   = queue(arrive_imm, service_imm, server_imm[[1]]),
      walk_imm     = distance_imm[1] / walk_speed
    ) %>%
    group_by(flight, nat) %>%
    mutate(
      n_bags       = rpois(n(), nu_bags[1]),
      arrive_bh    = depart_imm + walk_imm,
      walk_bh      = distance_bh[1] / walk_speed
    ) %>% ungroup()

  bag_table <- passenger_table %>%
    right_join(data_frame(ID = rep(.$ID, times = .$n_bags)), by = "ID") %>%
    group_by(flight, nat, handler) %>%
    mutate(
      arrive_bags  = arrive + lag_bags[1],
      service_bags = rexp(n(), rate_bags[1])
    ) %>%
    group_by(handler) %>%
    mutate(
      depart_bags  = queue(arrive_bags, service_bags, server_bags[1])
    ) %>%
    group_by(ID) %>%
    summarise(
      last_bag  = max(depart_bags)
    )

  passenger_table <- passenger_table %>%
    left_join(bag_table, by = "ID") %>%
    group_by(flight, nat, handler) %>%
    mutate(
      depart_bh    = pmax.int(arrive_bh, last_bag, na.rm = TRUE),
      arrive_cus   = depart_bh + walk_bh,
      service_cus  = rexp(n(), rate_cus[1]) * n_bags
    ) %>%
    group_by(n_bags == 0) %>%
    mutate(
      depart_cus   = queue(arrive_cus, service_cus, server_cus[[1]])
    ) %>%
    ungroup()

  passenger_table <- passenger_table %>%
    mutate(
      system_dpl   = arrive_ac     - arrive,
      system_ac    = arrive_imm    - arrive_ac,
      system_imm   = arrive_bh     - arrive_imm,
      system_bh    = arrive_cus    - arrive_bh,
      system_cus   = depart_cus    - arrive_cus,
      system_bags  = last_bag      - arrive,
      system_total = system_dpl + system_ac + system_imm + system_bh + system_cus,
      wait_imm     = depart_imm    - arrive_imm,
      wait_bh      = depart_bh     - arrive_bh,
      wait_cus     = depart_cus    - arrive_cus,
      wait_bags    = system_bags
    )

  return(passenger_table)
}





