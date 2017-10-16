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

# select rows
## select the first row (containing dates), and the rows containing prices in ops
# v_wheatKileSimple <- v_wheatKile[,c("date","quantity.2","quantity.3")]

## specify period
vDateStart <- as.Date("1875-01-01")
vDateStop <- as.Date("1914-12-31")
vCensorshipPeriod <- funcPeriod(vCensorship,vDateStart,vDateStop)

## create a subset of rows based on conditions
vCensorshipWarnings <- subset(vCensorshipPeriod,Action=="W")

# plot
## plot a time series
plotCensorshipTime <- ggplot(vCensorshipPeriod, aes(x = date, y = action)) +
  ggtitle("Censorship in Bilad al-Sham") +
  xlab("Date") + ylab("Action") +
  geom_point(na.rm=TRUE,color= "red",  size=3, pch=1) +
  scale_x_date(breaks=date_breaks("2 years"), labels=date_format("%Y")) +
  theme_bw() # make the themeblack-and-white rather than grey (do this before font changes, or it overridesthem)
plotCensorshipTime

## bar plot
plotCensorshipBar <- ggplot(vCensorshipPeriod, aes(x = action, fill = action)) +
  ggtitle("Censorship in Bilad al-Sham") +
  geom_bar() +
  theme_bw() # make the themeblack-and-white rather than grey (do this before font changes, or it overridesthem)
  
## trials
plotCensorshipTime1 <- ggplot(subset(vCensorshipPeriod,action=="S"), aes(x = date, y = action)) +
  ggtitle("Censorship in Bilad al-Sham") +
  xlab("Date") + ylab("Action") +
  geom_point(na.rm=TRUE,color= "red",  size=5, pch=1) +
  scale_x_date(breaks=date_breaks("2 years"), labels=date_format("%Y")) +
  theme_bw() # make the themeblack-and-white rather than grey (do this before font changes, or it overridesthem)
plotCensorshipTime1

# probe the data source
str(vCensorshipPeriod)
tableActionByNewspaper <- with(vCensorshipPeriod, table(newspaper,action))

# try to aggregate by year
actionAvgAnnual <- aggregate(vCensorshipPeriod$action, list(date=format(date, "%Y")),mean)

# compute monthly averages
##  Get months
vCensorshipPeriod$Month <- months(vCensorshipPeriod$date)

##  Get years
vCensorshipPeriod$Year <- format(vCensorshipPeriod$date,format="%Y")

##  Aggregate 'X2' on months and year and get mean
aggregate(action ~ Month + Year , vCensorshipPeriod , mean )
