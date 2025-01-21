# set a general theme for all ggplots
theme_set(theme_bw())

# labels
v.label.license = paste("Till Grallert ", lubridate::year(Sys.Date()), ", CC BY-SA 4.0", sep = "")

# colours
v.colour.map.fill = "#d9d8d7" # light grey
v.colour.map.border = "#b8b6b6" # dark grey
v.colour.dot.border = "#F2D902"
v.colour.dot.fill = "#FEFDB2"
v.colour.label = "#000426"
v.colour.lines = "#48417D"
v.colour.grey = "#b8b6b6"
v.colour.grey.light = "#e8e6e6" # "#dbd9d9"
v.colour.grey.dark = "#adabab"
v.colour.green = "#bcd8c5" #"#07AA00"
v.colour.green.dark =  "#07AA00"
v.colour.red.dark = "#871020"
v.colour.purple = "#8435d9"
# sizes
## in themes size is measured in px
size.Base.Px = 12
## font sizes are measured in mm
size.Base.Mm = (5/14) * size.Base.Px
# specify text sizes
size.Title = 2
size.Subtitle = 1.5
size.Text = 1
size.Axes = 1
## transformation to MM and PX
size.Title.Mm = size.Title * size.Base.Mm
size.Subtitle.Mm = size.Subtitle * size.Base.Mm
size.Text.Mm = size.Text * size.Base.Mm
size.Title.Px = size.Title * size.Base.Px
size.Subtitle.Px = size.Subtitle * size.Base.Px
size.Text.Px = size.Text * size.Base.Px
size.Axes.Px = size.Axes * size.Base.Px

# variables for saving plots
width.Plot <- 300
height.Plot <- 200
dpi.Plot <- 300
units.Plot <- "mm"
# DPI
dpi = 150

## font
font = "Baskerville"
font.Arab = "Amiri"

plot.timeline.base <- ggplot() +
    scale_x_date(breaks=date_breaks("2 years"), labels=date_format("%Y")) +
    theme(
        text = element_text(family = font, face = "plain", size = size.Text.Px),  # all text elements
        axis.text.x = element_text(angle = 45, vjust=0.5, hjust = 0.5,            # rotate x axis text
                                   size = size.Axes.Px),
        axis.text = element_text(size = size.Axes.Px),
        plot.title = element_text(size = size.Title.Px),
        plot.subtitle = element_text(size = size.Subtitle.Px),
        plot.caption = element_text(size = size.Text.Px * 0.8),
        legend.position = "right",
        panel.border = element_blank(), # remove border around plot area
        panel.grid.minor = element_blank(), # remove grid lines
        panel.grid.major.x = element_blank()
    )

