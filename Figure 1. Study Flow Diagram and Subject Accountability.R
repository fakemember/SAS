library(dplyr)
library(ggplot2)
library(extrafont)
#font_import() only do this one time - it takes a while
loadfonts(device="win")
windowsFonts(Times=windowsFont("TT Times New Roman"))




data <- tibble(x= 1:100, y= 1:100)
head(data)

data %>% 
  ggplot(aes(x, y)) +
  scale_x_continuous(minor_breaks = seq(10, 100, 10)) +
  scale_y_continuous(minor_breaks = seq(10, 100, 10)) +
  theme_linedraw() ->p

p +
  geom_rect(xmin = 36, xmax=64, ymin=94, ymax=100, color='black',
            fill='white', size=1, size=1) +
  annotate('text', x= 50, y=97,label= 'Assessed for eligibility (n=168)', size = 12/.pt) ->
  p


p +
  geom_rect(xmin = 32, xmax=68, ymin=73, ymax=83, color='black',
            fill='white', size=1) +
  annotate('text', x= 50, y=78,label= 'Randomized (n=148)', size=12/.pt) +
  geom_rect(xmin = 70, xmax=97, ymin=80, ymax=98, color='black',fill='white', size=1) +
  annotate('text', x= 72, y=89,hjust = 0,label= 'Excluded (n=20)                        \n      Not meeting Inclusion criteria (n=3)    \n      Meeting Exclusion criteria (n=17)', size=12/.pt) ->
  p


p +
  geom_segment(
    x=50, xend=50, y=94, yend=83.3, 
    size=0.8, linejoin = "mitre", lineend = "butt",
    arrow = arrow(length = unit(1, "mm"), type= "closed")) +
  geom_segment(
    x=50, xend=69.7, y=89, yend=89, 
    size=0.8, linejoin = "mitre", lineend = "butt",
    arrow = arrow(length = unit(1, "mm"), type= "closed")) ->
  p




p +
  
  # then 2nd arrow from the left, x and xend=30
  geom_segment(
    x=30, xend=30, y=65, yend=58.3, 
    size=0.8, linejoin = "mitre", lineend = "butt",
    arrow = arrow(length = unit(1, "mm"), type= "closed")) +
  # then 4th arrow from the left, x and xend=70
  geom_segment(
    x=70, xend=70, y=65, yend=58.3, 
    size=0.8, linejoin = "mitre", lineend = "butt",
    arrow = arrow(length = unit(1, "mm"), type= "closed")) +
  # then horizontal line, but remove the arrow
  geom_segment(
    x=30, xend=70, y=65, yend=65, 
    size=0.8, linejoin = "mitre", lineend = "butt")+
  geom_segment(
    x=50, xend=50, y=73, yend=65, 
    size=0.8, linejoin = "mitre", lineend = "butt")->p


p +
  #2nd box on left
  geom_rect(xmin = 16, xmax=44, ymin=39.5, ymax=58, 
            color='black', fill='white', size=1) +
  annotate('text', x= 22, y=49.2, size=12/.pt,hjust = 0,
           label= 'Allocated to Roll-in (n=50)\n     Received allocated\n     intervention (n=50)\n     Did not receive allocated\n     intervention (n=0)') +
  #4th box on left
  geom_rect(xmin = 56, xmax=84, ymin=39.5, ymax=58, 
            color='black', fill='white', size=1) +
  annotate('text', x= 62, y=49.2, size=12/.pt,hjust = 0,
           label= 'Allocated to Pivotal (n=98)\n     Received allocated\n     intervention (n=97)\n     Did not receive allocated\n     intervention (n=1)') ->
  p




p+ 
  # then 2nd arrow from the left, x and xend=30
  geom_segment(
    x=30, xend=30, yend=33.5, y=39.5, 
    size=0.8, linejoin = "mitre", lineend = "butt",
    arrow = arrow(length = unit(1, "mm"), type= "closed")) +
  # then 4th arrow from the left, x and xend=70
  geom_segment(
    x=70, xend=70, yend=33.5, y=39.5, 
    size=0.8, linejoin = "mitre", lineend = "butt",
    arrow = arrow(length = unit(1, "mm"), type= "closed"))->
  p




p +
  #2nd box on left
  geom_rect(xmin = 16, xmax=44, ymin=18, ymax=33.5, 
            color='black', fill='white', size=1) +
  annotate('text', x= 22, y=28, size=12/.pt,hjust = 0,
           label= 'Lost to follow up (n=1)          \nWithdrew consent (n=0) \nDeath (n=0)') +
  #4th box on left
  geom_rect(xmin = 56, xmax=84, ymin=18, ymax=33.5, 
            color='black', fill='white', size=1) +
  annotate('text', x= 62, y=28, size=12/.pt,hjust = 0,
           label= 'Lost to follow up (n=1)          \nWithdrew consent (n=1) \nDeath (n=1)') ->
  p


p+ 
  # then 2nd arrow from the left, x and xend=30
  geom_segment(
    x=30, xend=30, yend=14, y=18, 
    size=0.8, linejoin = "mitre", lineend = "butt",
    arrow = arrow(length = unit(1, "mm"), type= "closed")) +
  # then 4th arrow from the left, x and xend=70
  geom_segment(
    x=70, xend=70, yend=14, y=18, 
    size=0.8, linejoin = "mitre", lineend = "butt",
    arrow = arrow(length = unit(1, "mm"), type= "closed"))->
  p




p +
  #2nd box on left
  geom_rect(xmin = 16, xmax=44, ymin=2, ymax=14, 
            color='black', fill='white', size=1) +
  annotate('text', x= 22, y=10, size=12/.pt,hjust = 0,
           label= 'Analyzed (n=50) \n     Excluded from analysis (n=0)') +
  #4th box on left
  geom_rect(xmin = 56, xmax=84, ymin=2, ymax=14, 
            color='black', fill='white', size=1) +
  annotate('text', x= 62, y=10, size=12/.pt,hjust = 0,
           label= 'Analyzed (n=97) \n     Excluded from analysis (n=0)') ->
  p


p+  annotate('text', x=10, y=79,label= 'Enrollment', angle=90,size=12/.pt,fontface = "bold")+  
  annotate('text', x= 10, y=50,label= 'Allocation', angle=90,size=12/.pt,fontface = "bold")+
  annotate('text', x= 10, y=26,label= 'Follow-up',angle=90, size=12/.pt,fontface = "bold")+
  annotate('text', x= 10, y=8,label= 'Analysis',angle=90, size=12/.pt,fontface = "bold")->p


p+theme(text=element_text( family="serif"))->p


p + theme_void()
