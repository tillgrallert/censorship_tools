# Remember it is good coding technique to add additional packages to the top of
# your script 
library(lubridate) # for working with dates
library(ggplot2)  # for creating graphs
library(scales)   # to access breaks/formatting functions
library(gridExtra) # for arranging plots
library(plotly) # interactive plots based on ggplot
library(dplyr) # for data cleaning
library(plyr)

# function to create subsets for periods
funcPeriod <- function(f,x,y){f[f$date >= x & f$date <= y,]}

# use a working directory
#setwd("/Volumes/Dessau HD/BachUni/research-projects/censorship/censorship_data")
setwd("/BachUni/research-projects/censorship/censorship_data")

# 1. read price data from csv, note that the first row is a date
vCensorship <- read.csv("csv/censorship-levant.csv", header=TRUE, sep = ",", quote = "")
vLaws <- read.csv("csv/laws-press-ottoman-empire.csv", header=TRUE, sep = ",", quote = "")

# convert date to Date class
vCensorship$date <- as.Date(vCensorship$date)
vLaws$date <- as.Date(vLaws$date)

# aggregate periods
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

## do the same for laws
vLaws$year <- as.Date(cut(vLaws$date,
                                breaks = "year"))
vLaws$quarter <- as.Date(cut(vLaws$date,
                                   breaks = "quarter"))
vLaws$month <- as.Date(cut(vLaws$date,
                                 breaks = "month"))

# specify period
vDateStart <- as.Date("1857-01-01")
vDateStop <- as.Date("1916-12-31")
vCensorshipPeriod <- funcPeriod(vCensorship,vDateStart,vDateStop)
vLawsPeriod <- funcPeriod(vLaws,vDateStart,vDateStop)


## create a subset of rows based on conditions
vCensorshipPermits <- subset(vCensorshipPeriod,action=="P")
vCensorshipSuspensions <- subset(vCensorshipPeriod,action=="S")
vCensorshipWarnings <- subset(vCensorshipPeriod,action=="W")
vCensorshipEnd <- subset(vCensorshipPeriod,action=='CP')

# calculate totals
## annual totals, using the plyr package to get frequencies
vCensorshipPermitsAnnual <- count(vCensorshipPermits,'year')
vCensorshipSuspensionsAnnual <- count(vCensorshipSuspensions,'year')
vCensorshipWarningsAnnual <- count(vCensorshipWarnings,'year')

# limit to a specific location
## Bilād al-Shām
vLevant <- subset(vCensorshipPeriod, location %in% c('Aleppo','Baʿbdā','Beirut','Damascus','Haifa','Hama','Hebron',
                                                     'Homs','Jaffa','Jerusalem','Nablus','Latakia','Tripoli', 'Ottoman Empire',
                                                     'Syria'))
vBeirut <- subset(vCensorshipPeriod, location %in% c('Beirut'))
vDamascus <- subset(vCensorshipPeriod, location %in% c('Damascus', 'Syria'))

## Egypt
vEgypt <- subset(vCensorshipPeriod, location %in% c('Alexandria', 'Cairo', 'Egypt', 'Port Said'))
vMaghrib <- subset(vCensorshipPeriod, location %in% c('ALgiers', 'Tunis'))
vAbroad <- subset(vCensorshipPeriod, location %in% c('Buenos Aires','Livorno','London','Naples','New York','Paris', 'Rio di Janeiro'))
vEmpire <- subset(vCensorshipPeriod, location %in% c('Constantinople','Istanbul','Ottoman Empire'))
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
### histogram: restrictions in the Levant
plotLevantRestrictive <- ggplot()+
  labs(title="Censorship in Bilad al-Sham", 
       subtitle="Restrictions", 
       x="Date", 
       y="Frequency")+ # provides title, subtitle, x, y, caption
  geom_bar(data=vLevantRestrictive, aes(x=year,fill=action),position = "stack",width = 200)+
  #geom_bar(data=vCensorshipSuspensions, aes(x=year,fill=action),position = "stack",width = 200)+
  #geom_bar(data=vCensorshipWarnings, aes(x=year,fill=action),position = "stack",width = 200)+
  # layer: legal framework
  #geom_jitter(data=vLawsPeriod,(aes(x=year,y=10)),size=3)+
  geom_segment(data = vLawsPeriod, 
               aes(x = date, y =5.5, 
                   xend = date, yend = 8.5),
               na.rm = T, linetype=4, # linetypes: 1=solid, 2=dashed, 
               show.legend = NA, color = "black")+
  scale_x_date(breaks=date_breaks("2 years"), 
               labels=date_format("%Y"))+ #,
  # limits=as.Date(c(vDateStart, vDateStop))) +
  scale_y_continuous(breaks = waiver())+
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, vjust=0.5,hjust = 0.5, size = 8))  # rotate x axis text
plotLevantRestrictive

### histogramm: permissions in the Levant
plotLevantPermissive <- ggplot()+
  labs(title="Censorship in Bilad al-Sham", 
       subtitle="Permissions", 
       x="Date", 
       y="Frequency")+ # provides title, subtitle, x, y, caption
  geom_bar(data=vLevantPermissive, aes(x=year, fill=action),position = "stack", width = 200)+
  #geom_bar(data=vCensorshipPermits, aes(x=year, fill=action),position = "stack", width = 200)+
  # layer: legal framework
  geom_jitter(data=vLawsPeriod,(aes(x=year,y=10)),size=3)+
  scale_x_date(breaks=date_breaks("2 years"), 
               labels=date_format("%Y"))+ #,
  # limits=as.Date(c(vDateStart, vDateStop))) +
  scale_y_continuous(breaks = waiver())+
  theme_bw()
plotLevantPermissive

### histogram: suspensions in the Levant
plotLevantSuspensions <- ggplot()+
  labs(title="Censorship in Bilad al-Sham", 
       subtitle="Suspensions", 
       x="Date", 
       y="Frequency")+ # provides title, subtitle, x, y, caption
  geom_bar(data=vLevantSuspensions, aes(x=year,fill=action),position = "stack",width = 200)+
  #geom_bar(data=vCensorshipSuspensions, aes(x=year,fill=action),position = "stack",width = 200)+
  #geom_bar(data=vCensorshipWarnings, aes(x=year,fill=action),position = "stack",width = 200)+
  # layer: legal framework
  geom_jitter(data=vLawsPeriod,(aes(x=year,y=5)),size=3)+
  # layer: line for mean; problem: this does not take into account years without suspensions
  #geom_hline(yintercept = mean(count(vLevantSuspensions,'year')[,c('freq')]))+
  scale_x_date(breaks=date_breaks("2 years"), 
               labels=date_format("%Y"))+ #,
  # limits=as.Date(c(vDateStart, vDateStop))) +
  scale_y_continuous(breaks = waiver())+
  theme_bw()
plotLevantSuspensions

### histogram: suspensions in the Levant
plotLevantSuspensionsImplemented <- ggplot()+
  labs(title="Censorship in Bilad al-Sham", 
       subtitle="Suspensions", 
       x="Date", 
       y="Frequency")+ # provides title, subtitle, x, y, caption
  geom_bar(data=vLevantSuspensionsImplemented, aes(x=year,fill=action),position = "stack",width = 200)+
  #geom_bar(data=vCensorshipSuspensions, aes(x=year,fill=action),position = "stack",width = 200)+
  #geom_bar(data=vCensorshipWarnings, aes(x=year,fill=action),position = "stack",width = 200)+
  # layer: legal framework
  geom_jitter(data=vLawsPeriod,(aes(x=year,y=5)),size=3)+
  scale_x_date(breaks=date_breaks("2 years"), 
               labels=date_format("%Y"))+ #,
  # limits=as.Date(c(vDateStart, vDateStop))) +
  scale_y_continuous(breaks = waiver())+
  theme_bw()
plotLevantSuspensionsImplemented

### histogram: restrictions in Beirut
plotBeirutRestrictive <- ggplot()+
  labs(title="Censorship in Beirut", 
       subtitle="Restrictions", 
       x="Date", 
       y="Frequency")+ # provides title, subtitle, x, y, caption
  geom_bar(data=vBeirutRestrictive, aes(x=year,fill=action),position = "stack",width = 200)+
  #geom_bar(data=vCensorshipSuspensions, aes(x=year,fill=action),position = "stack",width = 200)+
  #geom_bar(data=vCensorshipWarnings, aes(x=year,fill=action),position = "stack",width = 200)+
  # layer: legal framework
  geom_jitter(data=vLawsPeriod,(aes(x=date,y=10)),size=3)+
  scale_x_date(breaks=date_breaks("2 years"), 
               labels=date_format("%Y"))+ #,
  # limits=as.Date(c(vDateStart, vDateStop))) +
  scale_y_continuous(breaks = waiver())+
  theme_bw()
plotBeirutRestrictive

### histogramm: permissions Beirut 
plotBeirutPermissive <- ggplot()+
  labs(title="Censorship in Beirut", 
       subtitle="Permissions", 
       x="Date", 
       y="Frequency")+ # provides title, subtitle, x, y, caption
  geom_bar(data=vBeirutPermissive, aes(x=year, fill=action),position = "stack", width = 200)+
  #geom_bar(data=vCensorshipPermits, aes(x=year, fill=action),position = "stack", width = 200)+
  # layer: legal framework
  geom_jitter(data=vLawsPeriod,(aes(x=year,y=10)),size=3)+
  scale_x_date(breaks=date_breaks("2 years"), 
               labels=date_format("%Y"))+ #,
  # limits=as.Date(c(vDateStart, vDateStop))) +
  scale_y_continuous(breaks = waiver())+
  theme_bw()
plotBeirutPermissive

### histogram: restrictions in Damascus
plotDamascusRestrictive <- ggplot()+
  labs(title="Censorship in Damascus", 
       subtitle="Restrictions", 
       x="Date", 
       y="Frequency")+ # provides title, subtitle, x, y, caption
  geom_bar(data=vDamascusRestrictive, aes(x=year,fill=action),position = "stack",width = 200)+
  #geom_bar(data=vCensorshipSuspensions, aes(x=year,fill=action),position = "stack",width = 200)+
  #geom_bar(data=vCensorshipWarnings, aes(x=year,fill=action),position = "stack",width = 200)+
  # layer: legal framework
  geom_jitter(data=vLawsPeriod,(aes(x=date,y=10)),size=3)+
  scale_x_date(breaks=date_breaks("2 years"), 
               labels=date_format("%Y"))+ #,
  # limits=as.Date(c(vDateStart, vDateStop))) +
  scale_y_continuous(breaks = waiver())+
  theme_bw()
plotDamascusRestrictive

### histogramm: permissions Damascus 
plotDamascusPermissive <- ggplot()+
  labs(title="Censorship in Damascus", 
       subtitle="Permissions", 
       x="Date", 
       y="Frequency")+ # provides title, subtitle, x, y, caption
  geom_bar(data=vDamascusPermissive, aes(x=year, fill=action),position = "stack", width = 200)+
  #geom_bar(data=vCensorshipPermits, aes(x=year, fill=action),position = "stack", width = 200)+
  # layer: legal framework
  geom_jitter(data=vLawsPeriod,(aes(x=year,y=10)),size=3)+
  scale_x_date(breaks=date_breaks("2 years"), 
               labels=date_format("%Y"))+ #,
  # limits=as.Date(c(vDateStart, vDateStop))) +
  scale_y_continuous(breaks = waiver())+
  theme_bw()
plotDamascusPermissive

### histogram: restrictions in Egypt
plotEgyptRestrictive <- ggplot()+
  labs(title="Censorship in Egypt", 
       subtitle="Restrictions", 
       x="Date", 
       y="Frequency")+ # provides title, subtitle, x, y, caption
  geom_bar(data=vEgyptRestrictive, aes(x=year,fill=action),position = "stack",width = 200)+
  #geom_bar(data=vCensorshipSuspensions, aes(x=year,fill=action),position = "stack",width = 200)+
  #geom_bar(data=vCensorshipWarnings, aes(x=year,fill=action),position = "stack",width = 200)+
  # layer: legal framework
  geom_jitter(data=vLawsPeriod,(aes(x=date,y=10)),size=3)+
  scale_x_date(breaks=date_breaks("2 years"), 
               labels=date_format("%Y"))+ #,
  # limits=as.Date(c(vDateStart, vDateStop))) +
  scale_y_continuous(breaks = waiver())+
  theme_bw()
plotEgyptRestrictive

### histogramm: permissions in Egypt
plotEgyptPermissive <- ggplot()+
  labs(title="Censorship in Egypt", 
       subtitle="Permissions", 
       x="Date", 
       y="Frequency")+ # provides title, subtitle, x, y, caption
  geom_bar(data=vEgyptPermissive, aes(x=year, fill=action),position = "stack", width = 200)+
  #geom_bar(data=vCensorshipPermits, aes(x=year, fill=action),position = "stack", width = 200)+
  # layer: legal framework
  geom_jitter(data=vLawsPeriod,(aes(x=year,y=10)),size=3)+
  scale_x_date(breaks=date_breaks("2 years"), 
               labels=date_format("%Y"))+ #,
  # limits=as.Date(c(vDateStart, vDateStop))) +
  scale_y_continuous(breaks = waiver())+
  theme_bw()
plotEgyptPermissive

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
               # limits=as.Date(c(vDateStart, vDateStop))) +
  scale_y_continuous(breaks = waiver())+
  theme_bw() # make the themeblack-and-white rather than grey (do this before font changes, or it overridesthem)
plotActionFrequency

## plot a time series for all 
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

## bar plot: one bar for each action
plotCensorshipBar <- ggplot(vCensorshipPeriod, aes(x = action)) +
  labs(title="Censorship in Bilad al-Sham", 
       # subtitle="based on announcements in newspapers", 
       x="Action", 
       y="Aggregate number of incidents")+ # provides title, subtitle, x, y, caption
  geom_bar(aes(fill=action)) +
  # geom_density(aes(fill=action))+ # density makes no sense in this context
  theme_bw() # make the themeblack-and-white rather than grey (do this before font changes, or it overridesthem)
plotCensorshipBar
  
## bar plot for aggregated periods using `stat_sum`
plotCensorshipBarAggr <- ggplot(data = vCensorshipPeriod, aes(x = year, # selects the period
                                       y=action,
                                       color=action)) +
  labs(title="Censorship in Bilad al-Sham", 
       # subtitle="based on announcements in newspapers", 
       x="Date", 
       y="Action")+ # provides title, subtitle, x, y, caption
  stat_summary(data=subset(vCensorshipPeriod,action=="S"),
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
               limits=as.Date(c(vDateStart, vDateStop))) + # if plotting more than one graph, it is helpful to provide the same limits for each
  theme_bw() # make the themeblack-and-white rather than grey
plotCensorshipBarAggr

## Plot individual actions
plotCensorshipTime1 <- ggplot(subset(vCensorshipPeriod,action=="P"), aes(x = date, y = action)) +
  ggtitle("Censorship in Bilad al-Sham") +
  xlab("Date") + ylab("Action") +
  geom_point(na.rm=TRUE,color= "red",  size=5, pch=1) +
  scale_x_date(breaks=date_breaks("2 years"), labels=date_format("%Y")) +
  theme_bw() # make the themeblack-and-white rather than grey (do this before font changes, or it overridesthem)
plotCensorshipTime1

