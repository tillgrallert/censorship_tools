# Remember it is good coding technique to add additional packages to the top of
# your script 
library(lubridate) # for working with dates
library(ggplot2)  # for creating graphs
library(scales)   # to access breaks/formatting functions
library(gridExtra) # for arranging plots
library(plotly) # interactive plots based on ggplot

# function to create subsets for periods
funcPeriod <- function(f,x,y){f[f$date >= x & f$date <= y,]}

# use a working directory
setwd("/Volumes/Dessau HD/BachUni/research-projects/censorship/censorship_data")

# 1. read price data from csv, note that the first row is a date
vCensorship <- read.csv("csv/censorship-levant.csv", header=TRUE, sep = ",", quote = "")

# convert date to Date class
vCensorship$date <- as.Date(vCensorship$date)

# aggregate periods
## there is an option to add a column that contains the year as string, but this is not particularly helpful
vCensorship$year <-format(vCensorship$date,format="%Y")

## use cut() to generate summary stats for time periods
## create variables of the year, quarter week and month of each observation:
vCensorship$year <- as.Date(cut(vCensorship$date,
                                breaks = "year"))
vCensorship$quarter <- as.Date(cut(vCensorship$date,
                                   breaks = "quarter"))
vCensorship$month <- as.Date(cut(vCensorship$date,
                                 breaks = "month"))
vCensorship$week <- as.Date(cut(vCensorship$date,
                                breaks = "week",
                                start.on.monday = TRUE)) # allows to change weekly break point to Sunday

# select rows
## select the first row (containing dates), and the rows containing prices in ops
# v_wheatKileSimple <- v_wheatKile[,c("date","quantity.2","quantity.3")]

## specify period
vDateStart <- as.Date("1875-01-01")
vDateStop <- as.Date("1914-12-31")
vCensorshipPeriod <- funcPeriod(vCensorship,vDateStart,vDateStop)

## create a subset of rows based on conditions
vCensorshipWarnings <- subset(vCensorshipPeriod,action=="W")
vCensorshipSuspensions <- subset(vCensorshipPeriod,action=="S")
vCensorshipPermits <- subset(vCensorshipPeriod,action=="P")

# plot
## plot a time series
plotCensorshipTime <- ggplot(vCensorshipPeriod, aes(x = quarter, y = action)) +
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

## bar plot
plotCensorshipBar <- ggplot(vCensorshipPeriod, aes(x = action, fill = action)) +
  ggtitle("Censorship in Bilad al-Sham") +
  geom_bar() +
  theme_bw() # make the themeblack-and-white rather than grey (do this before font changes, or it overridesthem)
  
## bar plot for aggregated periods using `stat_sum`
plotCensorshipBarAggr <- ggplot(data = vCensorship, aes(x = year, # selects the period
                                       y=action, fill=action)) +
  ggtitle("Censorship in Bilad al-Sham") + # plot label
  xlab("Date") + ylab("Action") + # axis labels
  stat_summary(fun.y = sum, # adds up all observations for the period
               geom = "bar", # or "line"
               na.rm=TRUE) + # remove all empty/invalid levels
  #geom_text(label=stat_summary(fun.y = sum),
  #          vjust = -1) + # adding values to the top of the bars
  #geom_label(aes(label=action), 
  #          na.rm = TRUE,
  #          size=2) + # add labels to individual values
  scale_x_date(breaks=date_breaks("2 years"), 
               labels=date_format("%Y"),
               limits=as.Date(c(vDateStart, vDateStop))) + # if plotting more than one graph, it is helpful to provide the same limits for each
  theme_bw() # make the themeblack-and-white rather than grey
plotCensorshipBarAggr

## trials
plotCensorshipTime1 <- ggplot(subset(vCensorshipPeriod,action=="P"), aes(x = date, y = action)) +
  ggtitle("Censorship in Bilad al-Sham") +
  xlab("Date") + ylab("Action") +
  geom_point(na.rm=TRUE,color= "red",  size=5, pch=1) +
  scale_x_date(breaks=date_breaks("2 years"), labels=date_format("%Y")) +
  theme_bw() # make the themeblack-and-white rather than grey (do this before font changes, or it overridesthem)
plotCensorshipTime1

# output
plotCensorshipBar
