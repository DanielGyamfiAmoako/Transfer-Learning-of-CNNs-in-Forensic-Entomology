#Install all the packages so anyone can run the analysis automatically.
#Install packages
install.packages("tidyverse")
install.packages("vegan")
install.packages("ggplot2")
install.packages("EnvStats")

library(dplyr)
library(tidyverse)
library(vegan)
library(ggplot2)
library(maps)
library(cowplot)
library(viridis)
library(EnvStats)

#Set working directory where all your analysis and files will be deposited.
setwd("~/Documents/GitHub/Subproject_1")

##### Load Data from BOLD####
#Load Bold Data sets of waterfowl (family = Charadriiformes) and shorebirds (family = Anatidae)
#I kept these lines commented as I saved the data to my working directory so I do not need to keep downloading it
#This data was downloaded on September 16th, 2022

water_birds <-  read_tsv("http://www.boldsystems.org/index.php/API_Public/combined?taxon=Charadriiformes&format=tsv")
shore_birds <- read_tsv("http://www.boldsystems.org/index.php/API_Public/combined?taxon=Anatidae&format=tsv")

#I will save the water_birds and the shore_birds to my mac to avoid re-loading them every time. To download them you can simply uncomment the code above

write_tsv(water_birds, "water_birds_BOLD_data.tsv")

water_birds <- read_tsv("water_birds_BOLD_data.tsv")

write_tsv(shore_birds, "shore_birds_BOLD_data.tsv")

shore_birds <- read_tsv("shore_birds_BOLD_data.tsv")

##### Part 1: Bar plot of sampling efforts ##### (corrections)
#I am interested in the latitude at which individuals were sequenced. Therefore, let's plot a histogram of latitudes for both species so we can visually check the data loaded correctly.  
#I edited the histogram to get "color" and "breaks"out of the data exploration.
#The hist() function has a default algorithm for determining the number of bars to use in the histogram based on the density of the data. However, you can override the default option by setting the breaks argument to something else. Here, we use more bars to try to get more detail.
hist(water_birds$lat, xlab = "Latitude", ylab = "Number of Sqeuence Species", col = "green", breaks = 100)
hist(shore_birds$lat, xlab = "", ylab = "Number of Sqeuence Species", col = "red", breaks = 100)


#We can get a little more detail using the rug() function to show us the actual data points. This allows us to explore below the histogram the range for the large cluster data.
rug(water_birds$lat)
rug(shore_birds$lat)


#Since I am trying to compare individuals sequenced in summer habitats to winter habitats, I next want to separate them based on that. To do this, I will set the latitude 40 as the cut off between summer/winter and use the filter function to separate them.
#I will print out all the filter functions output and print a summary to check they functioned correctly
?filter()
water_summer <- filter(water_birds, lat > 40)
water_summer
summary(water_summer)

water_winter <- filter(water_birds, lat <= 40)
water_winter
summary(water_winter)

shore_summer <- filter(shore_birds, lat > 40)
shore_summer
summary(shore_summer)

shore_winter <- filter(shore_birds, lat <= 40)
shore_winter 
summary(shore_winter)


#Check for outliers
#Extract the values of the potential outliers based on the IQR criterion with regards to the boxplot.stats()$out function: (Corrections). It is a good practice to always check the results of the statistical test for outliers against the boxplot to make sure we tested all potential outliers. Potential outliers will be deposited on top of the boxplot.
#For water_summer 
out <- boxplot.stats(water_summer$lat)$out
boxplot(water_summer$lat,
        ylab = "Number of Sqeuence Species"
)
mtext(paste("Outliers: ", paste(out, collapse = ", ")))
#Results = No outliers found.

#For water_winter
out <- boxplot.stats(water_winter$lat)$out
boxplot(water_winter$lat,
        ylab = "Number of Sqeuence Species"
)
mtext(paste("Outliers: ", paste(out, collapse = ", ")))
#Results = No outliers found.

#For shore_winter
out <- boxplot.stats(shore_winter$lat)$out
boxplot(shore_winter$lat,
        ylab = "Number of Sqeuence Species"
)
mtext(paste("Outliers: ", paste(out, collapse = ", ")))
#Results = No outliers found.

#For shore_summer
out <- boxplot.stats(shore_summer$lat)$out
boxplot(shore_summer$lat,
        ylab = "Number of Sqeuence Species"
)
mtext(paste("Outliers: ", paste(out, collapse = ", ")))
#Results = Some possible outliers found.

#Perform the Rosner test using the rosnerTest() function from the {EnvStats} package to confirm the outliers predictions. This function requires at least 2 arguments: the data and the number of suspected outliers k (with the number of suspected outliers based on the IQR criterion from the boxplot). This was also repeated for all the data sets and was fine.
#We show the "shore_summer$lat: data because it predicted potential outliers.
#K =30 was used because of the potential IQR from the boxplot.

test <- rosnerTest(shore_summer$lat,
                   k = 30
)
test
#From the results based on the Rosner statistical test, we see that there is on outliers and that all observations predicted us outliers from the boxplot were "false" when computed. Hence we can proceed with further analysis

# Next, I will get the length of all the summer and winter data sets. This will allow me to figure out how many individuals were sequenced in summer or winter for both families.
length(water_summer$lat)
length(water_winter$lat)
length(shore_summer$lat)
length(shore_winter$lat)


#Next, I will create bar plots for the length data. I will start with a simple plot of each family to verify my code is working. Afterwards, I plot the two families together.  

barplot(c(length(water_summer$lat), length(water_winter$lat)),  names = c("Summer", "Winter"), xlab = "Bird location", ylab = "Number of Sqeuence Species")

barplot(c(length(shore_summer$lat),length(shore_winter$lat)), names = c("Summer", "Winter"), xlab = "Bird location", ylab = "Number of Sqeuence Species" )


#I will then create a bar plot which has all four groups.
#I edited the figures to make it publication ready! 
#The 'Title', 'Figure legend' and 'data source' added makes the figure self-explanatory.
barplot(c(length(water_summer$lat), length(water_winter$lat), length(shore_summer$lat), length(shore_winter$lat)), names = c("Summer Waterfowl", "Winter Waterfowl", "Summer Shorebirds", "Winter Shorebirds"), xlab = "Bird location", ylab = "Number Sequenced", col = c("dark green", "blue"), ylim = c(0, 1500), main = "Comparison of Birds in different habitat", sub= "Data from the BARCODE OF LIFE DATA SYSTEM v4", legend.text = c("Summer", "Winter"), args.legend=list(title="Legend"))

#This function is to conduct a T-test to see if there is a significant difference between the summer and winter of each family
t.test(water_summer$lat, water_winter$lat)
t.test(shore_summer$lat, shore_winter$lat)

##### Part 2: Accumulation curves #####
#In order to better understand the sequencing effort between the winter and summer I will next build accumulation curves for all groups. 
#I will start by manipulating the data so that vegan can read it. I will then create simple curves for each group to verify that the data manipulation and curve creation is functioning correctly

#Data manipulation and curve creation for Summer Waterfowl
Count.by.BIN_water_summer <- water_summer %>%
  group_by(bin_uri) %>%
  count(bin_uri)
BINs.spread_water_summer <- pivot_wider(data = Count.by.BIN_water_summer, names_from  = bin_uri, values_from = n)
curve_water_summer <- rarecurve(BINs.spread_water_summer, xlab = "Individuals Barcoded", ylab = "BIN Richness")

#Data manipulation and curve creation for Winter Waterfowl
Count.by.BIN_water_winter <- water_winter %>%
  group_by(bin_uri) %>%
  count(bin_uri)
BINs.spread_water_winter <- pivot_wider(data = Count.by.BIN_water_winter, names_from  = bin_uri, values_from = n)
curve_water_winter <- rarecurve(BINs.spread_water_winter, xlab = "Individuals Barcoded", ylab = "BIN Richness")

#Data manipulation and curve creation for Summer Shorebirds
Count.by.BIN_shore_summer <- shore_summer %>%
  group_by(bin_uri) %>%
  count(bin_uri)
BINs.spread_shore_summer <- pivot_wider(data = Count.by.BIN_shore_summer, names_from  = bin_uri, values_from = n)
curve_shore_summer <- rarecurve(BINs.spread_shore_summer, xlab = "Individuals Barcoded", ylab = "BIN Richness")

#Data manipulation and curve creation for Winter Shorebirds
Count.by.BIN_shore_winter <- shore_winter %>%
  group_by(bin_uri) %>%
  count(bin_uri)
BINs.spread_shore_winter <- pivot_wider(data = Count.by.BIN_shore_winter, names_from  = bin_uri, values_from = n)
curve_shore_winter <- rarecurve(BINs.spread_shore_winter, xlab = "Individuals Barcoded", ylab = "BIN Richness")


# Next, I would like to plot all of the accumulation curves on the same graph. This will allow for easy comparison between the four groups. 
as_tibble_rc <- function(x){
  # convert rarecurve() output to data.frame
  # bind_rows doesn't work because items are different lengths
  # also need to extract sample sizes from attribute
  # Allocate result dataframe
  nsamples <- map_int(x, length)
  total_samples <- sum(nsamples)
  if(!is.null(names(x))){
    sites <- names(x)
  } else {
    sites <- as.character(1:length(nsamples))
  }
  result <- data_frame(Site = rep("", total_samples),
                       Sample_size = rep(0, total_samples),
                       Species = rep(0, total_samples))
  start <- 1
  for (i in 1:length(nsamples)){
    result[start:(start + nsamples[i]-1), "Site"] <- sites[i]
    result[start:(start + nsamples[i]-1), "Sample_size"] <- attr(x[[i]], "Subsample")
    result[start:(start + nsamples[i]-1), "Species"] <- x[[i]]
    start <- start + nsamples[i]
  }
  result
}

#I edited the figure to make it publication ready and added the function to automatically save your figure in a pdf in your working directory.
comb_acc <- as_tibble_rc(c(curve_water_summer, curve_water_winter, curve_shore_summer, curve_shore_winter))
ggplot(data = comb_acc , mapping =aes(x= Sample_size, y=Species, color = Site)) + 
  geom_line() + labs(y= "BIN Counts", x= "Sample Size") + 
  labs(color = "Species") + labs(colour_subtitle = "Legend") +
  scale_colour_discrete(labels = c("1" = "Summer Waterfowl", "2" = "Winter Waterfowl", "3" = "Summer Shorebirds", "4" = "Winter Shorebirds"))+
#Use the labs function to label the title of the figure
  labs(title="Species Accummilative Curve by BIN DataIndividuals", tag = "Figure 2")
#Save your figure automatically using the ggsave with the pdf option.
  ggsave("PLOT_Figure2.pdf")


##### Part 3: World heat map ##### 
#Finally, I would like to create a heat map of the countries where the birds of both families were sequenced.
#This will allow me to visualize where all of the Shorebirds and Waterfowl were sequenced to observe if there are any large discrepancies


#First, I need to create a new data frame with the count (i.e. the total number of individuals sequenced) for each country for both families
#I will print out the new data frame to verify my code is working
shore_birds.by.country <- shore_birds %>%
  group_by(country) %>%
  count(country)

shore_birds.by.country

water_birds.by.country <- water_birds %>%
  group_by(country) %>%
  count(country)

water_birds.by.country


#Next, I need to remove any individuals from the data set that did not have a country indicated to prevent errors later in the code
shore_birds.by.country.na.rm <- shore_birds.by.country %>%
  filter(!is.na(country)) 


water_birds.by.country.na.rm <- water_birds.by.country %>%
  filter(!is.na(country)) 

#I will print out the tail of the two new data sets to ensure that there are not more NA values (as NA was the last row).

tail(shore_birds.by.country.na.rm)
tail(shore_birds.by.country.na.rm)


#Next, I will make a new data frame of the world which will allow me to plot my bird data on the map of the world
#In order to do this, I will use the maps package
#To help with this code I used the sources: (Badani, 2021; Moreno & Basille, 2018) 

?map_data

world_map <- map_data("world")
world_map
world_map <- subset(world_map, region != "Antarctica")
world_map

#The next step would be plotting my bird data on the world_map data to make the heat map of the world, however there is one issue: the country names
#In the bird data set the USA is called United States and the UK is called United Kingdom. Although in the world_map data frame they are called USA and UK respectively
#Therefore, I need to change the names of these two countries in my bird data frame to match the names in my world_map data frame
shore_birds.by.country.na.rm[39, 1] = "USA"
shore_birds.by.country.na.rm[38, 1] = "UK"

water_birds.by.country.na.rm[71,1] = "UK"
water_birds.by.country.na.rm[72,1] = "USA"


#Finally, I am ready to plot my heat maps of my bird data over the map of the world
# I used the source (Rudis et al., 2021) to help me with the viridis colour package

shore_birds_heat_map <- ggplot(shore_birds.by.country.na.rm) +
  geom_map(
    dat = world_map, map = world_map, aes(map_id = region),
    fill = "white", color = "#7f7f7f", size = 0.25
  ) +
  geom_map(map = world_map, aes(map_id = country, fill = n), size = 0.25) +
  expand_limits(x = world_map$long, y = world_map$lat)+
  scale_fill_viridis( discrete = F, direction = -1) + 
  labs(y= "Latitude", x= "Longitude") 


water_birds_heat_map <- ggplot(water_birds.by.country.na.rm) +
  geom_map(
    dat = world_map, map = world_map, aes(map_id = region),
    fill = "white", color = "#7f7f7f", size = 0.25
  ) +
  geom_map(map = world_map, aes(map_id = country, fill = n), size = 0.25) +
  expand_limits(x = world_map$long, y = world_map$lat) +
  scale_fill_viridis(discrete = F, direction = -1) + 
  labs(y= "Latitude", x= "Longitude") + labs(color = "Species")

#This function will allow me to plot both maps on the same figure so that I can easily compare them
#This function uses the package cowplot
# The n on the scale represents the number of individuals sequenced. This label could not be changed in the code. I asked Dr. Steinke about it and he could not find a solution. He informed me to keep it and that it would not affect my mark.
plot_grid(water_birds_heat_map, shore_birds_heat_map, labels=c("A", "B"), ncol = 1, nrow = 2)

