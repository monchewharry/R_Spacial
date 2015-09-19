library(ggmap)    

# quick map plot
qmap(location = "wisconsin university madison",zoom = 14, source = "osm")   
## qmap is a wrapper for get_map and ggmap. get_map is a smart wrapper 
## that queries the map server of your choosing—Google Maps, OpenStreetMap, 
## or Stamen Maps—and returns a map at a specified location. 


# Visualizing clusters
mydata = read.csv("vehicle-accidents.csv")  
head(mydata)
mydata$State <- as.character(mydata$State)  
mydata$MV.Number = as.numeric(mydata$MV.Number)  
mydata = mydata[mydata$State != "Alaska", ]  
mydata = mydata[mydata$State != "Hawaii", ]  
mydata = mydata[mydata$State != "USA",]

## find the longitude and latitude  
# for (i in 1:nrow(mydata)) {  
#   latlon = geocode(mydata[i,1],source = "google")
#   mydata$lon[i] = as.numeric(latlon[1])
#   mydata$lat[i] = as.numeric(latlon[2])
# }  

mv_num_collisions = data.frame(mydata$MV.Number, mydata$lon, mydata$lat)
colnames(mv_num_collisions) = c('collisions','lon','lat')  
save(mv_num_collisions,file="mv_num_collisions.RData")
load("mv_num_collisions.RData")

## plot the number of collisions per state with varying sizes of circles  
usa_center = as.numeric(geocode("United States",source = "google"))
USAMap = ggmap(get_googlemap(center=usa_center, scale=2, zoom=4), extent="normal") 

## We use the + to add ggplot2 geometric objects and other styling options on top of the map.
## Next we add the geom_point geom to the map and generate aesthetic mappings with aes that 
## describe how variables in the data are mapped to visual properties (aesthetics) of geoms.
## Finally, the size and scale of each circle is based on the minimum and maximum value 
## range of collision amounts per state.
ggsave(filename = "collisions.png")
circle_scale_amt= 0.1
USAMap +  
  geom_point(aes(x=lon, y=lat), data=mv_num_collisions, col="red", alpha=0.4, 
             size=mv_num_collisions$collisions*circle_scale_amt) +  
  scale_size_continuous(range=range(mv_num_collisions$collisions))  

# Heat maps  
## Let’s try one more plot type—the heat map.for insurance insights, 
## the next dataset looks at concentration of homes in a region and when those homes were built.

tartu_housing <- read.csv("tartu_housing_xy_wgs84_a.csv", sep = ";")
tartu_map_g_str <- get_map(location = "tartu", zoom = 13,source = "google")# Download the base map
ggsave(filename = "home_heat.png")
ggmap(tartu_map_g_str, extent = "device") + #draw a gg_map on top
  geom_density2d(data = tartu_housing, aes(x = lon, y = lat), size = 0.3) + 
     #Perform a 2D kernel density estimation using kde2d and display the results with contours.
  stat_density2d(data = tartu_housing, 
                 aes(x = lon, y = lat, fill = ..level.., alpha = ..level..), size = 0.01, 
                 bins = 16, geom = "polygon") + # 2D density estimation
  scale_fill_gradient(low = "green", high = "red") + 
  scale_alpha(range = c(0, 0.3), guide = FALSE)# Sets alpha value for transparency.
