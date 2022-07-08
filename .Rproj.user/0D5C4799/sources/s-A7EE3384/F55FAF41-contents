# Author: Maxwell Chirehwa
# Purpose: Plot target engagement and exposure
# Date created: 07 July 2022
# Date modified: XXXXX

viz_output <- function(mydf, y_var, threshhold = NULL) {
  
  ggplot(mydf) +
    aes(
      x = .data[["time"]],
      y = .data[[y_var]]
    ) +
    geom_line() +
    geom_hline(yintercept = threshhold, color = "red", linetype = 2) +
    # scale_x_continuous(breaks = seq(1, 29, by = 7)) +
    theme_bw(base_size = 20 )
}

# Example to plot TargetEng
# viz_output(mydf = c1 %>% filter(doseid == 1 & cohort_n == 1),
#            y_var = 'TargetEng', threshhold = 80)
