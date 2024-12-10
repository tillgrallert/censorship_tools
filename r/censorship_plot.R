# Remember it is good coding technique to add additional packages to the top of
# your script
library(tidyverse)
library(lubridate) # for working with dates
library(scales)   # to access breaks/formatting functions
library(gridExtra) # for arranging plots
library(here)

# load functions and variables/parameters
#source(here("../../../BachBibliothek/GitHub/Sihafa/sihafa_tools/r/functions.R"))
# load variables/parameters
source(here("r","parameters.R"))

# function to create subsets for periods
funcPeriod <- function(f,x,y){f[f$date >= x & f$date <= y,]}

# 1. load data
setwd(here("../censorship_data/csv/"))
data.laws <- readr::read_csv("laws-press-ottoman-empire.csv", col_names = T, trim_ws = T)
data.censorship <- readr::read_csv("censorship-levant_processed.csv", col_names = T, trim_ws = T)

# plot
## basic timeline plot
plot.timeline.base <- ggplot() +
    scale_x_date(breaks=date_breaks("2 years"), labels=date_format("%Y")) +
    theme(
        axis.text.x = element_text(angle = 45, vjust=0.5, hjust = 0.5, size = 8),  # rotate x axis text
        text = element_text(family = font, face = "plain"),
        plot.title = element_text(size = size.Title.Px),
        plot.subtitle = element_text(size = size.Subtitle.Px),
        plot.caption = element_text(size = size.Text.Px),
        legend.position = "right",
        panel.border = element_blank(), # remove border around plot area
        panel.grid.minor = element_blank(), # remove grid lines
        panel.grid.major.x = element_blank()
    )

## plot frequencies of actions
f.plot.censorship <- function(data.events, label.location, label.subtitle) {
    # process data
    data.events <- data.events %>%
        dplyr::group_by(action, year) %>%
        dplyr::summarise(events = n()) %>%
        dplyr::ungroup() %>%
        tidyr::drop_na()
    plot.timeline.base +
        labs(x = "",
             y = "events",
             title = paste("The press regime in ", label.location, sep = ""),
             subtitle = label.subtitle,
             caption = v.label.license) + # provides title, subtitle, x, y, caption
        geom_bar(data = data.events,
                 aes(x = year, y = events
                     #fill = action)
                 ),
                 stat="identity",
                 #position = "stack",
                 fill = "black",
                 width = 200) +
        # add a layer for laws
        geom_segment(data = funcPeriod(data.laws, as.Date('1875-01-01'), as.Date('1914-12-31')),
                     aes(x = date, y = 0,
                         xend = date, yend = max(data.events$events)),
                     na.rm = T, linetype=4, # linetypes: 1=solid, 2=dashed,
                     show.legend = NA, color = v.colour.grey.dark)
}
# plots by type
## implemented suspensions
plot.censorship.s.implemented <-f.plot.censorship(
    dplyr::filter(data.censorship,
                  action == c("S"), # only suspensions
                  cert == "high",   # high certitude, meaning implemented
                  !publication.loc %in% c("Cairo", "Istanbul", "Salonica")), # remove places of publication
    'Bilād al-Shām', 'Suspensions that correspond to gaps in publication')
plot.censorship.s.implemented
## all suspensions
plot.censorship.s <- f.plot.censorship(
    dplyr::filter(data.censorship,
                  action == c("S"),
                  !publication.loc %in% c("Cairo", "Istanbul", "Salonica")),
    'Bilād al-Shām', 'Suspensions issued by the authorities')
## warnings: only issued to newspapers form Beirut
plot.censorship.w <- f.plot.censorship(
    dplyr::filter(data.censorship,
                  action == c("W")),
    'Bilād al-Shām', 'Warnings issued by the authorities')
# save plots
setwd(here("../censorship_data", "plots"))
height.Plot = 130
width.Plot = 200
ggsave(plot = plot.censorship.s.implemented,
    filename = "plot_censorship-s-implemented.png",
    units = units.Plot , height = height.Plot, width = width.Plot, dpi = dpi.Plot)
ggsave(plot = plot.censorship.s,
       filename = "plot_censorship-s.png",
       units = units.Plot , height = height.Plot, width = width.Plot, dpi = dpi.Plot)
ggsave(plot = plot.censorship.w,
       filename = "plot_censorship-w.png",
       units = units.Plot , height = height.Plot, width = width.Plot, dpi = dpi.Plot)

#f.plot.censorship(dplyr::filter(data.censorship, action == c("S", "W", "BI")), 'Beirut and Damascus', '') +
 #   facet_wrap(~ action, ncol = 3)

f.plot.censorship.dots <- function(data.events,  label.location, label.subtitle) {
    # data processing
    # plot
    plot.timeline.base +
    labs(x = "",
         y = "events",
         title = paste("The press regime in ", label.location, sep = ""),
         subtitle = label.subtitle,
         caption = v.label.license) +
    geom_point(data = data.events, aes(x = date, y = action),
               shape = 21, color = "black", fill = v.colour.grey,
               size = 10, stroke = 0.5, alpha = 0.3) +
        geom_segment(data = funcPeriod(data.laws, as.Date('1875-01-01'), as.Date('1914-12-31')),
                     aes(x = date, xend = date,
                         y = "S", yend = "W"),
                     na.rm = T, linetype = 4, # linetypes: 1=solid, 2=dashed,
                     show.legend = T, color = v.colour.grey.dark) +
        theme(legend.position = "bottom")
}

plot.censorship.dots <- f.plot.censorship.dots(
    dplyr::filter(data.censorship,
                  action %in% c("W", "S"),
                  !publication.loc %in% c("Alexandria","Cairo","Istanbul", "Salonica")),
    'Beirut and Damascus', 'Warnings and suspensions issued by the authorities')
ggsave(plot = plot.censorship.dots,
       filename = "plot_censorship_dots.png",
       units = units.Plot , height = 80, width = 400, dpi = dpi.Plot)
ggsave(plot = plot.censorship.dots,
       filename = "plot_censorship_dots.svg",
       units = units.Plot , height = 80, width = 400, dpi = dpi.Plot)

f.plot.censorship.dots(
    dplyr::filter(data.censorship,
                  #action %in% c("W", "S"),
                  !publication.loc %in% c("Alexandria","Cairo","Istanbul", "Salonica")),
    'Beirut and Damascus', 'Warnings and suspensions issued by the authorities')
