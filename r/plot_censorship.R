# Remember it is good coding technique to add additional packages to the top of
# your script
library(tidyverse)
library(lubridate) # for working with dates
library(scales)   # to access breaks/formatting functions
library(gridExtra) # for arranging plots
library(here)

# load functions and variables/parameters
source(here("../../../BachBibliothek/GitHub/Sihafa/sihafa_tools/r/functions.R"))
# load variables/parameters
source(here("../../../BachBibliothek/GitHub/Sihafa/sihafa_tools/r/parameters.R"))

# function to create subsets for periods
funcPeriod <- function(f,x,y){f[f$date >= x & f$date <= y,]}

# use a working directory
setwd(here("../censorship_data/csv/"))

# 1. read price data from csv, note that the first row is a date
#data.censorship.old <- read.csv("censorship-levant_old.csv", header=TRUE, sep = ",", quote = "")
data.laws <- read.csv("laws-press-ottoman-empire.csv", header=TRUE, sep = ",", quote = "")
data.censorship <- read.csv("censorship-levant.csv", header=TRUE, sep = ",", quote = "\"")

# convert date to Date class
#data.censorship.old$date <- as.Date(data.censorship.old$date)
data.laws$date <- as.Date(data.laws$date)

# aggregate periods
## use cut() to generate summary stats for time periods
## create variables of the year, quarter week and month of each observation:

data.censorship <- data.censorship %>%
  dplyr::mutate(date = as.Date(date.documented),
                year = as.Date(cut(date, breaks = "year")),
                quarter = as.Date(cut(date, breaks = "quarter")),
                month = as.Date(cut(date, breaks = "month")),
                week = as.Date(cut(date, breaks = "week", start.on.monday = TRUE))
                ) %>%
    tidyr::drop_na(date.documented) %>%
    dplyr::rename(action = subtype)
# filter for specific types
data.censorship.s <- data.censorship %>%
  dplyr::filter(action == "S")
data.censorship.w <- data.censorship %>%
  dplyr::filter(action == "W")
# available titles, i.e. those, which I could check for gaps
data.censorship.s.imp <- data.censorship.s %>%
    dplyr::filter(cert == "high")
unique(data.censorship.s.imp$publication.id)
data.censorship.s.titles.available <- data.censorship.s %>%
    subset(publication.id %in% unique(data.censorship.s.imp$publication.id))
# aggregate by title
data.censorship.s.titles.available.wide <- data.censorship.s.titles.available %>%
    dplyr::group_by(publication.id, publication.title, publication.loc.id, publication.loc, cert) %>%
    dplyr::summarise(events = n()) %>%
    dplyr::ungroup()# %>%
    tidyr::pivot_wider(names_from = cert, values_from = events) %>%
    dplyr::arrange(desc("S"))

data.censorship.aggr.periodical <- data.censorship %>%
    dplyr::group_by(publication.id, publication.title, publication.loc.id, publication.loc, action) %>%
    dplyr::summarise(events = n()) %>%
    dplyr::ungroup() %>%
    dplyr::arrange(desc(events, publication.title))
## make into wide table
data.censorship.aggr.periodical.wide <- data.censorship.aggr.periodical %>%
    dplyr::filter(action %in% c("S", "W", "BI", "PR")) %>%
    tidyr::pivot_wider(names_from = action, values_from = events) %>%
    dplyr::arrange(desc("S", "W"))

write.table(data.censorship.aggr.periodical.wide, "censorship_by-periodical.csv" , row.names = F, quote = T , sep = ",")

# aggregate data by year
data.censorship.aggr.year <- data.censorship %>%
  dplyr::group_by(action, cert, year) %>%
  dplyr::summarise(events = n()) %>%
  dplyr::ungroup() %>%
    tidyr::drop_na(year) %>%
    dplyr::arrange(year)
## make into wide table
data.censorship.aggr.year.wide <- data.censorship.aggr.year %>%
    dplyr::group_by(action, year) %>%
    dplyr::summarise(events = sum(events)) %>%
    dplyr::filter(action %in% c("S", "W", "BI", "PR")) %>%
    tidyr::pivot_wider(names_from = action, values_from = events) %>%
    dplyr::arrange(year)

write.table(data.censorship.aggr.year.wide, "censorship_by-year.csv" , row.names = F, quote = T , sep = ",")

w <- data.censorship.aggr.year %>%
    dplyr::filter(action == "W")
s <- data.censorship.aggr.year %>%
    dplyr::filter(action == "S")
s.imp <- data.censorship.aggr.year %>%
    dplyr::filter(action == "S",
                  cert == "high")
sum(w$events)
sum(s$events)
sum(s.imp$events)
f.percent(sum(s$events), sum(s.imp$events))

# plot
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
plot.censorship.s.implemented <-f.plot.censorship(dplyr::filter(data.censorship, action == c("S"), !publication.loc %in% c("Alexandria", "Istanbul"), cert == "high"), 'Beirut and Damascus', 'Suspensions that correspond to gaps in publication')
plot.censorship.s.implemented
plot.censorship.s <- f.plot.censorship(dplyr::filter(data.censorship, action == c("S"), !publication.loc %in% c("Alexandria", "Istanbul")), 'Beirut and Damascus', 'Suspensions issued by the authorities')
plot.censorship.w <- f.plot.censorship(dplyr::filter(data.censorship, action == c("W")), 'Beirut and Damascus', 'Warnings issued by the authorities')
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

plot.censorship.dots <- f.plot.censorship.dots(dplyr::filter(data.censorship, action %in% c("W", "S"), !publication.loc %in% c("Alexandria", "Istanbul")), 'Beirut and Damascus', 'Warnings and suspensions issued by the authorities')
ggsave(plot = plot.censorship.dots,
       filename = "plot_censorship_dots.png",
       units = units.Plot , height = 80, width = 400, dpi = dpi.Plot)
# old stuff

data.censorship.old <- data.censorship.old.%>%
  dplyr::mutate(year = as.Date(cut(date, breaks = "year")),
                quarter = as.Date(cut(date, breaks = "quarter")),
                month = as.Date(cut(date, breaks = "month")),
                week = as.Date(cut(date, breaks = "week", start.on.monday = TRUE)) # allows to change weekly break point to Sunday))
                )

## do the same for laws
data.laws <- data.laws %>%
  dplyr::mutate(year = as.Date(cut(date, breaks = "year")),
                quarter = as.Date(cut(date, breaks = "quarter")),
                month = as.Date(cut(date, breaks = "month"))
  )

# specify period
v.onset <- as.Date("1857-01-01")
v.terminus <- as.Date("1914-12-31")
data.censorship.oldPeriod <- funcPeriod(data.censorship.old,v.onset,v.terminus)
data.lawsPeriod <- funcPeriod(data.laws,v.onset,v.terminus)


## create a subset of rows based on conditions
data.censorship.oldPermits <- subset(data.censorship.oldPeriod,action=="P")
data.censorship.oldSuspensions <- subset(data.censorship.oldPeriod,action=="S")
data.censorship.oldWarnings <- subset(data.censorship.oldPeriod,action=="W")
data.censorship.oldEnd <- subset(data.censorship.oldPeriod,action=='CP')

# calculate totals
## annual totals, using the plyr package to get frequencies
data.censorship.oldPermitsAnnual <- count(data.censorship.oldPermits,'year')
data.censorship.oldSuspensionsAnnual <- count(data.censorship.oldSuspensions,'year')
data.censorship.oldWarningsAnnual <- count(data.censorship.oldWarnings,'year')

# limit to a specific location
## Bilād al-Shām
vLevant <- subset(data.censorship.oldPeriod, location %in% c('Aleppo','Baʿbdā','Beirut','Damascus','Haifa','Hama','Hebron',
                                                     'Homs','Jaffa','Jerusalem','Nablus','Latakia','Tripoli', 'Ottoman Empire',
                                                     'Syria'))
vBeirut <- subset(data.censorship.oldPeriod, location %in% c('Beirut'))
vDamascus <- subset(data.censorship.oldPeriod, location %in% c('Damascus', 'Syria'))

## Egypt
vEgypt <- subset(data.censorship.oldPeriod, location %in% c('Alexandria', 'Cairo', 'Egypt', 'Port Said'))
vMaghrib <- subset(data.censorship.oldPeriod, location %in% c('ALgiers', 'Tunis'))
vAbroad <- subset(data.censorship.oldPeriod, location %in% c('Buenos Aires','Livorno','London','Naples','New York','Paris', 'Rio di Janeiro'))
vEmpire <- subset(data.censorship.oldPeriod, location %in% c('Constantinople','Istanbul','Ottoman Empire'))
# Yemen, Iraq, Iran, India still missing

# grouping types of action: Levant
vLevantRestrictive <- subset(vLevant, action %in% c('S','W','Trial','Raid','BI','CP'))
vLevantPermissive <- subset(vLevant, action %in% c('1','P','PI','PR','RP'))
vLevantPermits <- subset(vLevant,action %in% c('P'))
vLevantSuspensions <- subset(vLevant,action %in% c('S'))
vLevantSuspensionsImplemented <- subset(vLevantSuspensions,implemented %in% c('yes'))
vLevantWarnings <- subset(vLevant,action %in% c('W'))

## descriptive stats
### restrictions
mean(count(vLevantSuspensions,'year')[,c('freq')])
median(count(vLevantSuspensions,'year')[,c('freq')])
sd(count(vLevantSuspensions,'year')[,c('freq')])

# grouping types of action: Beirut
vBeirutRestrictive <- subset(vBeirut, action %in% c('S','W','Trial','Raid','BI','CP'))
vBeirutPermissive <- subset(vBeirut, action %in% c('1','P','PI','PR','RP'))
vBeirutPermits <- subset(vBeirut,action %in% c('P'))
vBeirutSuspensions <- subset(vBeirut,action %in% c('S'))
vBeirutWarnings <- subset(vBeirut,action %in% c('W'))

# grouping types of action: Damascus
vDamascusRestrictive <- subset(vDamascus, action %in% c('S','W','Trial','Raid','BI','CP'))
vDamascusPermissive <- subset(vDamascus, action %in% c('1','P','PI','PR','RP'))
vDamascusPermits <- subset(vDamascus,action %in% c('P'))
vDamascusSuspensions <- subset(vDamascus,action %in% c('S'))
vDamascusWarnings <- subset(vDamascus,action %in% c('W'))

# grouping types of action: Egypt
vEgyptRestrictive <- subset(vEgypt, action %in% c('S','W','Trial','Raid','BI','CP'))
vEgyptPermissive <- subset(vEgypt, action %in% c('1','P','PI','PR','RP'))
vEgyptPermits <- subset(vEgypt,action %in% c('P'))
vEgyptSuspensions <- subset(vEgypt,action %in% c('S'))
vEgyptWarnings <- subset(vEgypt,action %in% c('W'))

# plot
## plot frequencies of actions
f.plot <- function(data.events, label.location, label.subtitle) {
  ggplot()+
    labs(x = "Date",
         y = "Frequency",
         title = paste("The press regime in ", label.location, sep = ""),
         subtitle = label.subtitle,
         caption = "Till Grallert, CC BY-SA 4.0")+ # provides title, subtitle, x, y, caption
    geom_bar(data = data.events,
             aes(x = year,
                 fill = action),
             position = "stack",width = 200) +
    # add a layer for laws
    geom_segment(data = data.lawsPeriod,
                 aes(x = date, y = 0,
                     xend = date, yend = 3.5),
                 na.rm = T, linetype=4, # linetypes: 1=solid, 2=dashed,
                 show.legend = NA, color = "black")+
    scale_x_date(breaks=date_breaks("2 years"), labels=date_format("%Y")) +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 45, vjust=0.5,hjust = 0.5, size = 8))  # rotate x axis text
}
## variables for saving plots
width.Plot <- 400
height.Plot <- width.Plot / 2
dpi.Plot <- 300
units.Plot <- "mm"
setwd("/BachUni/research-projects/censorship/censorship_data/plots")


### histogram: restrictions in the Levant
plot.LevantRestrictive <- f.plot(data.events = vLevantRestrictive, label.location = "Bilād al-Shām", label.subtitle = "Restrictions")
ggsave(filename = "plot_levant-restrictive.png",
       plot = plot.LevantRestrictive,
       units = units.Plot , height = height.Plot, width = width.Plot, dpi = dpi.Plot)
plot.LevantRestrictive
### histogramm: permissions in the Levant
plot.LevantPermissive <- f.plot(data.events = vLevantPermissive, label.location = "Bilād al-Shām", label.subtitle = "Permissions")
ggsave(filename = "plot_levant-permissive.png",
       plot = plot.LevantPermissive,
       units = units.Plot , height = height.Plot, width = width.Plot, dpi = dpi.Plot)
plot.LevantPermissive
### histogram: suspensions in the Levant
plot.LevantSuspensions <- f.plot(data.events = vLevantSuspensions, label.location = "Bilād al-Shām", label.subtitle = "Suspensions")
ggsave(filename = "plot_levant-suspensions.png",
       plot = plot.LevantSuspensions,
       units = units.Plot , height = height.Plot, width = width.Plot, dpi = dpi.Plot)
plot.LevantSuspensions
plot.LevantSuspensionsImplemented <- f.plot(data.events = vLevantSuspensionsImplemented, label.location = "Bilād al-Shām", label.subtitle = "Implemented suspensions")
plot.LevantSuspensionsImplemented




### use individual layers
plotActionFrequency <- ggplot()+
  labs(title="Censorship in Bilad al-Sham",
       subtitle="based on announcements in newspapers",
       x="Date",
       y="Frequency")+ # provides title, subtitle, x, y, caption
  # layer: suspensions
  geom_line(data=count(subset(vLevant,action=="S"),'year'),aes(x=year, y=freq),na.rm=TRUE,color="#E32006",size=1)+
  #geom_bar(data=count(subset(vLevant,action=="S"),'year'), stat='identity', aes(x=year, y=freq), na.rm=TRUE, width = 5, color="#E32006", fill="#E32006")+
  # layer: warnings
  geom_line(data=count(subset(vLevant,action=="W"),'year'),aes(x=year, y=freq),na.rm=TRUE,color="#871020",size=1)+
  #geom_bar(data=count(subset(vLevant,action=="W"),'year'), stat='identity', aes(x=year, y=freq), na.rm=TRUE, width = 5, color="#871020", fill="#871020")+
  # layer: permits
  geom_line(data=count(subset(vLevant,action=="P"),'year'),aes(x=year, y=freq),na.rm=TRUE,color="#209A00",size=1)+
  #geom_bar(data=count(subset(vLevant,action=="P"),'year'), stat='identity', aes(x=year, y=freq), na.rm=TRUE, width = 5, color="#209A00", fill="#209A00")+
  scale_x_date(breaks=date_breaks("2 years"),
               labels=date_format("%Y"))+ #,
               # limits=as.Date(c(v.onset, v.terminus))) +
  scale_y_continuous(breaks = waiver())+
  theme_bw() # make the themeblack-and-white rather than grey (do this before font changes, or it overridesthem)
plotActionFrequency

## plot a time series for all
plotCensorshipTime <- ggplot(data.censorship.oldPeriod, aes(x = quarter, y = action)) +
  labs(title="Censorship in Bilad al-Sham",
       # subtitle="based on announcements in newspapers",
       x="Date",
       y="Action")+ # provides title, subtitle, x, y, caption
  geom_point(aes(col=action), # color, size, shape, stroke can be made dependent on columns
             na.rm=TRUE,
             size=3,
             pch=1) + # shape
  scale_x_date(breaks=date_breaks("2 years"), labels=date_format("%Y")) +
  theme_bw() + # make the themeblack-and-white rather than grey (do this before font changes, or it overridesthem)
  theme(legend.position="None")  # remove legend
plotCensorshipTime

## bar plot: one bar for each action
plotCensorshipBar <- ggplot(data.censorship.oldPeriod, aes(x = action)) +
  labs(title="Censorship in Bilad al-Sham",
       # subtitle="based on announcements in newspapers",
       x="Action",
       y="Aggregate number of incidents")+ # provides title, subtitle, x, y, caption
  geom_bar(aes(fill=action)) +
  # geom_density(aes(fill=action))+ # density makes no sense in this context
  theme_bw() # make the themeblack-and-white rather than grey (do this before font changes, or it overridesthem)
plotCensorshipBar

## bar plot for aggregated periods using `stat_sum`
plotCensorshipBarAggr <- ggplot(data = data.censorship.oldPeriod, aes(x = year, # selects the period
                                       y=action,
                                       color=action)) +
  labs(title="Censorship in Bilad al-Sham",
       # subtitle="based on announcements in newspapers",
       x="Date",
       y="Action")+ # provides title, subtitle, x, y, caption
  stat_summary(data=subset(data.censorship.oldPeriod,action=="S"),
               fun.y = sum, # adds up all observations for the period
               geom = "line", # or "line"
               na.rm=TRUE) + # remove all empty/invalid levels
  #coord_cartesian(ylim = c(0, 20)) +
  #geom_text(label=stat_summary(fun.y = sum),
  #          vjust = -1) + # adding values to the top of the bars
  #geom_label(aes(label=action),
  #          na.rm = TRUE,
  #          size=2) + # add labels to individual values
  scale_x_date(breaks=date_breaks("2 years"),
               labels=date_format("%Y"),
               limits=as.Date(c(v.onset, v.terminus))) + # if plotting more than one graph, it is helpful to provide the same limits for each
  theme_bw() # make the themeblack-and-white rather than grey
plotCensorshipBarAggr

## Plot individual actions
plotCensorshipTime1 <- ggplot(subset(data.censorship.oldPeriod,action=="P"), aes(x = date, y = action)) +
  ggtitle("Censorship in Bilad al-Sham") +
  xlab("Date") + ylab("Action") +
  geom_point(na.rm=TRUE,color= "red",  size=5, pch=1) +
  scale_x_date(breaks=date_breaks("2 years"), labels=date_format("%Y")) +
  theme_bw() # make the themeblack-and-white rather than grey (do this before font changes, or it overridesthem)
plotCensorshipTime1
