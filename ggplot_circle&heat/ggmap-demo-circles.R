# Package source URL: http://cran.r-project.org/web/packages/ggmap/ggmap.pdf
# Data source URL: http://www-fars.nhtsa.dot.gov/States/StatesCrashesAndAllVictims.aspx

install.packages("ggmap")
library(ggmap)

# load and clean the data
mydata = read.csv("data/vehicle-accidents.csv")
mydata$State <- as.character(mydata$State)
mydata$MV.Number = as.numeric(mydata$MV.Number)
mydata = mydata[mydata$State != "Alaska", ]
mydata = mydata[mydata$State != "Hawaii", ]
mydata = mydata[mydata$State != "USA", ]

# get the latitude/longitude for each state
for (i in 1:nrow(mydata)) {
  latlon = geocode(mydata[i,1])
  mydata$lon[i] = as.numeric(latlon[1])
  mydata$lat[i] = as.numeric(latlon[2])
}

# let's just pull out the number of motor vehicle collisions into a new data frame
mv_num_collisions = data.frame(mydata$MV.Number, mydata$lon, mydata$lat)
colnames(mv_num_collisions) = c('collisions','lon','lat')

# time to plot # of collisions per state using a Google map of the US-of-A
circle_scale_amt = 0.1 # make the circles 10% of the size!
usa_center = as.numeric(geocode("United States"))
USAMap = ggmap(get_googlemap(center=usa_center, scale=2, zoom=4), extent="normal")
USAMap + 
  geom_point(aes(x=lon, y=lat), data=mv_num_collisions, col="orange", alpha=0.4, 
                    size=mv_num_collisions$collisions*circle_scale_amt) + 
  scale_size_continuous(range=range(mv_num_collisions$collisions))

