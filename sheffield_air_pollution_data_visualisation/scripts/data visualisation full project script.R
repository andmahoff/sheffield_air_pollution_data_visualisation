##R script for the visualisation of how NO2 levels change in Sheffield over time for the years 2022-2025##

##Data Gathering and Cleaning##

#Required package download
#install.packages(c(
# "tidyverse", "janitor", "naniar", 
# "lubridate", "ggpattern"))

#Load required packages
library(tidyverse) #for data wrangling and visualisation
library(janitor)   #for cleaning column names
library(naniar)    #for checking missing data
library(lubridate) #for date manipulation
library(ggpattern) #for pattern fills in ggplot

#Set working directory - for example
#setwd("C:/Users/Andrzej user/Documents/Data Science/Data Visualisation/Assessment/R")

#Import air pollution files
air_pollution_raw <- read.csv("Air pollution data hourly.csv",na.strings=c("No data","NA"))
#View imported raw data
#View(air_pollution_raw)


#Clean dataframe
#Remove first 9 rows - metadata
air_pollution <- air_pollution_raw %>%
  slice(-c(1:9))
#Remove last 4 rows - empty
air_pollution <- air_pollution %>%
  slice(-c((nrow(air_pollution)-3):nrow(air_pollution)))
#Make first row the column names
colnames(air_pollution) <- as.character(unlist(air_pollution[1, ]))
#Make column names syntactically valid
colnames(air_pollution) <- make.names(colnames(air_pollution), unique = TRUE)
#Use janitor clean_names function to clean column names
air_pollution <- air_pollution |> janitor::clean_names()
#Remove status columns
air_pollution <- air_pollution %>%
  select(-contains("Status"))
#Change nitrogen_dioxide part of column names to NO2 for simplicity
colnames(air_pollution) <- gsub("nitrogen_dioxide", "NO2", colnames(air_pollution))
#Rename time column to hour column
colnames(air_pollution)[colnames(air_pollution) == "time"] <- "hour"
#Remove first row
air_pollution <- air_pollution %>%
  slice(-1)

#Check for missing data and NA values using ggvar
#gg_miss_var(air_pollution)

#Make all NO2 columns numeric
air_pollution <- air_pollution %>%
  mutate(across(contains("NO2"), as.numeric))
#Change date column to POSIXct format 
air_pollution$date <- as.Date(air_pollution$date, format = "%d/%m/%Y")
#Convert hour column into just hour data using lubridate package
air_pollution$hour <- period_to_seconds(hms(air_pollution$hour))/3600
air_pollution <- air_pollution %>%
  mutate(
    date = if_else(hour == 24, date + days(1), date),
    hour = if_else(hour == 24.00, 0.00, hour),
  )
#Add missing value for hour 0.00 on the first date of dataframe
air_pollution <- air_pollution %>%
  add_row(
    date = as.Date("2022-01-01"),
    hour = 0.00,
    NO2 = 21.8079,
    NO2_1 = 12.97158,
    NO2_2 = 7.16551,          
    .before = 1             
  )
#Create column saying which day of the week it is 
air_pollution$day_of_week <- weekdays(air_pollution$date)
#Create NO2 average column
air_pollution <- air_pollution %>%
  rowwise() %>%
  mutate(NO2_average = mean(c_across(contains("NO2")), na.rm = TRUE)) %>%
  ungroup()
#Create column that contains the average NO2 for each day
air_pollution <- air_pollution %>%
  group_by(date) %>%
  mutate(daily_NO2_average = mean(NO2_average, na.rm = TRUE)) %>%
  ungroup()
#View cleaned dataframe
#View(air_pollution)

##Create variables for visualisations##
#Create new dataframe that contains the hourly average NO2 for each day of the week 
hourly_NO2 <- air_pollution %>%
group_by(day_of_week, hour) %>%
  summarise(
    hourly_NO2_average = mean(NO2_average, na.rm = TRUE),     
    count = n(),                        
    .groups = "drop"                    
  ) 
#Order days of the week Monday to Sunday
hourly_NO2 <- hourly_NO2 %>%
  mutate(day_of_week = factor(day_of_week, levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))) %>%
  arrange(day_of_week)
#Add a daytype column to hourly_no2 dataframe
hourly_NO2 <- hourly_NO2 %>%
  mutate(
    day_type = ifelse(day_of_week %in% c("Saturday", "Sunday"), "Weekend", "Weekday")
  )
#View created dataframe
#View(hourly_NO2)


##Create variables for visualisation 1 - lineplot comparing weekday and weekend NO2 levels##
#Create dataframe for average hourly NO2 levels for weekday vs weekend
weekday_weekend_NO2 <- hourly_NO2 %>%
  group_by(day_type, hour) %>%
  summarise(hourly_day_type_NO2_average = mean(hourly_NO2_average, na.rm = TRUE), .groups = "drop")
#View created dataframe
#View(weekday_weekend_NO2)
#Create dataframe for direct labelling of lines at hour 23
weekday_weekend_NO2_legends <- weekday_weekend_NO2 %>%
  filter(hour == 23)


##Create variables for visualisation 2 - boxplot showing seasonal variation in air quality##
#Create dataframe with seasonal data
seasonal_data <- air_pollution %>%
  mutate(
    month_label = month(date, label = TRUE, abbr = TRUE),
    month_label = factor(month_label, levels = c("Dec", "Jan", "Feb", "Mar", 
                                                 "Apr", "May", "Jun", "Jul", 
                                                 "Aug", "Sep", "Oct", "Nov")),
    season = case_when(
      month_label %in% c("Dec", "Jan", "Feb") ~ "Winter",
      month_label %in% c("Mar", "Apr", "May") ~ "Spring",
      month_label %in% c("Jun", "Jul", "Aug") ~ "Summer",
      month_label %in% c("Sep", "Oct", "Nov") ~ "Autumn"
    ),
    season = factor(season, levels = c("Winter", "Spring", "Summer", "Autumn"))
  )
#View created dataframe
#View(seasonal_data)


##Create variables for visualisation 3 - monthly NO2 averages by year line graph (2022-2025)##
#Aggregate data by year and month
annual_comparison_NO2 <- air_pollution %>%
  mutate(
    year = factor(year(date)),      
    month = month(date, label = TRUE, abbr = TRUE) 
  ) %>%
  group_by(year, month) %>%
  summarise(
    monthly_NO2_average = mean(NO2_average, na.rm = TRUE),
    .groups = "drop"
  )
annual_comparison_NO2_legends <- annual_comparison_NO2 %>%
  filter(month == "Dec")
#Find months with biggest variance across years to highlight in visualisation
monthly_ranges <- annual_comparison_NO2 %>%
  group_by(month) %>%
  summarise(
    min_val = min(monthly_NO2_average, na.rm = TRUE),
    max_val = max(monthly_NO2_average, na.rm = TRUE),
    range_diff = max_val - min_val
  ) %>%
  arrange(desc(range_diff)) %>%
  slice(1:3)


##Create variables for visualisation 4 - heatmap showing annual hourly NO2 average for each year compared to 2022##
#Create dataframe for heatmap comparison
annual_NO2_heatmap_comparison <- air_pollution %>%
  mutate(year = year(date)) %>%
  filter(year %in% 2022:2025) %>%
  group_by(year, hour) %>%
  summarise(annual_hourly_NO2_average = mean(NO2_average, na.rm = TRUE), .groups = "drop") %>%
  pivot_wider(names_from = year, values_from = annual_hourly_NO2_average, names_prefix = "Y") %>%
  mutate(
    `2023` = Y2023 - Y2022,
    `2024` = Y2024 - Y2022,
    `2025` = Y2025 - Y2022
  ) %>%
  select(hour, `2023`, `2024`, `2025`) %>%
  pivot_longer(
    cols = -hour, 
    names_to = "comparison", 
    values_to = "difference"
  )
#Define peak traffic times for patterning in heatmap
peak_traffic_times <- data.frame(
  ymin = c(6.5, 15.5),   # Start times (7am, 4pm)
  ymax = c(10.5, 19.5),  # End times (10am, 7pm)
  label = c("Morning Rush", "Evening Rush")
)


## Data Visualisation ##

#Create standard theme for all ggplot graphs
standard_theme <- theme_minimal() +
  theme(
    plot.title = element_text(size = 25, face = "bold", hjust = 0.5, color = "#2c3e50", margin = margin(b = 5)),
    plot.subtitle = element_text(size = 18, hjust = 0.5, color = "grey40", margin = margin(b = 20)),
    plot.caption = element_text(size = 12.5, color = "grey40", margin = margin(t = 15)),
    axis.title.x = element_text(margin = margin(t = 10), size = 20),
    axis.title.y = element_text(margin = margin(r = 10), size = 20),
    axis.text.x = element_text(size = 18),
    axis.text.y = element_text(size = 18),
    #panel.grid.minor = element_blank(),         
    panel.grid.major.x = element_line(color = "grey90", linetype = "dashed"),
    panel.grid.major.y = element_line(color = "grey90", linetype = "dashed"),
  )

#Create standard mean diamond aesthetics
standard_mean_diamond <- stat_summary(
  fun = mean,
  geom = "point",
  shape = 23,
  size = 2.7, 
  fill = "black",
  color = "black",
  stroke = 1
) 

#Define standard season colours
standard_season_colours <- scale_fill_manual(values = c(
  "Winter" = "#80cdc1",  #Light Blue
  "Spring" = "#018571",  #Green
  "Summer" = "#dfc27d",  #Yellow
  "Autumn" = "#a6611a"  #Dark Brown
))

cols <- c("Weekday" = "#d8b365", "Weekend" = "#5ab4ac")
shapes <- c(21, 24)

## Visualisation 1 graph ##
#Create line graph comparing average weekday and weekend NO2 levels
ggplot(weekday_weekend_NO2, aes(x = hour, y = hourly_day_type_NO2_average, color = day_type, group = day_type)) +
  annotate(
    "rect",
    xmin = 7,
    xmax = 10,
    ymin = -Inf,
    ymax = Inf, 
    fill = "grey70",
    alpha = 0.2
  ) +
  annotate(
    "rect",
    xmin = 16,
    xmax = 19,
    ymin = -Inf,
    ymax = Inf, 
    fill = "grey70",
    alpha = 0.2
  ) +
  annotate(
    "text",
    x = 8.5,
    y = Inf,
    label = "Morning\nTraffic Peak", 
   vjust = 2,
   color = "grey40",
   fontface = "italic",
   size = 4
  ) +
  annotate(
    "text",
    x = 17.5,
    y = Inf,
    label = "Evening\nTraffic Peak", 
    vjust = 2,
    color = "grey40",
    fontface = "italic",
    size = 4
  ) +
  geom_line(linewidth = 1.2) +
  geom_point(
    aes(shape = day_type),
    size = 2.5,
    fill = "white",
    stroke = 1.5
  ) +
  geom_text(
    data = weekday_weekend_NO2_legends,      
    aes(label = day_type, y = hourly_day_type_NO2_average + ifelse(day_type == "Weekday", 0.55, -0.55)), 
    hjust = 0,
    nudge_x = 0.2,           
    fontface = "bold",
    size = 7
  ) +
  scale_color_manual(values = cols) +
  scale_shape_manual(values = c(
    "Weekday" = 21, #Circle
    "Weekend" = 24  #Triangle
  )) +
  scale_x_continuous(
    breaks = seq(0, 23, 2),
    labels = function(x) sprintf("%02d:00", x), 
    expand = expansion(mult = c(0.007, 0.08)) 
  ) +
  scale_y_continuous(expand = expansion(mult = c(0.68, 0.45))) +
  labs(
    title = "Workweek vs Weekend NO2 Levels in Sheffield",
    subtitle = "Average Hourly Nitrogen Dioxide (NO2) Levels in Sheffield for Workweek and Weekend days",
    caption = "Data Source: Sheffield Air Quality Monitoring Network | Visualization: Student 250215478",
    x = NULL,
    y = "Concentration of NO2 (µg/m³)",
    color = NULL,
    shape = NULL
  ) +
  standard_theme +
  theme(
    legend.position = "none"
  )

## Visualisation 2 graph ##
#Create box plot showing seasonal variation of daily NO2 levels
ggplot(seasonal_data, aes(x = month_label, y = daily_NO2_average, fill = season)) +
  geom_boxplot_pattern(
    aes(pattern = season),       
    pattern_color = "white",     
    pattern_fill = "white",      
    pattern_alpha = 0.1,         
    pattern_density = 0.3,       
    pattern_spacing = 0.02,      
    outlier.shape = 21, 
    outlier.size = 2, 
    outlier.fill = "grey80", 
    outlier.alpha = 0.5,
    alpha = 0.7,         
    width = 0.65,         
    color = "grey20"
  ) +
  scale_pattern_manual(values = c(
    "Winter" = "stripe", 
    "Spring" = "circle", 
    "Summer" = "crosshatch", 
    "Autumn" = "none"
  )) +
  standard_mean_diamond +
  standard_season_colours +
  scale_y_continuous(expand = expansion(mult = c(0.1, 0.13))) +
  guides(fill = guide_legend(nrow = 2, byrow = TRUE)) +
  labs(
    title = "Seasonal Patterns in NO2 Levels in Sheffield",
    subtitle = "Monthly distribution colored by Season (Diamond = Mean)",
    caption = "Data Source: Sheffield Air Quality Monitoring Network | Visualization:Student 250215478",
    x = NULL, 
    y = "Concentration of NO2 (µg/m³)"
  ) +
  standard_theme +
  theme(
    legend.position = c(0.918, 0.937),
    legend.background = element_rect(fill = "white", color = NA),
    legend.key.size = unit(2.2, "lines"),
    legend.text = element_text(size = 15),
    legend.title = element_blank()
  )

## Visualisation 3 ##
#Create line graph comparing annual NO2 levels from 2022 to 2025 with shading for volatile months
ggplot(annual_comparison_NO2, aes(x = month, y = monthly_NO2_average, color = year, group = year)) +
  geom_rect(
    data = monthly_ranges,
    aes(
      xmin = as.numeric(month) - 0.5, 
      xmax = as.numeric(month) + 0.5, 
      ymin = -Inf, 
      ymax = Inf
    ),
    inherit.aes = FALSE, 
    fill = "grey85", 
    alpha = 0.4
  ) +
  annotate(
    "text",
    x = 2.5,
    y = Inf, 
    label = "Months with\nHighest Variance",
    vjust = 2, 
    color = "grey50",
    size = 3.5,
    fontface = "italic"
  ) +
  annotate(
    "text",
    x = 12,
    y = Inf, 
    label = "Months with\nHighest Variance",
    vjust = 2, 
    color = "grey50",
    size = 3.5,
    fontface = "italic"
  ) +
  geom_line(
    linewidth = 1.2,
     alpha = 0.8
    ) +
  geom_point(
    aes(shape = year),
    size = 3,
    fill = "white",
    stroke = 1.5
  ) +
  geom_text(
    data = annual_comparison_NO2_legends,      
    aes(label = year, y = monthly_NO2_average), 
    hjust = 0,
    nudge_x = 0.10,           
    fontface = "bold",
    size = 7
  ) +
  scale_color_manual(values = c(
    "2022" = "#ca0020", 
    "2023" = "#f4a582", 
    "2024" = "#92c5de", 
    "2025" = "#0571b0"  
  )) +
  scale_shape_manual(values = c(
    "2022" = 21, 
    "2023" = 22, 
    "2024" = 24, 
    "2025" = 23
  )) +
  scale_y_continuous(expand = expansion(mult = c(0.675, 0.32))) +
  scale_x_discrete(expand = expansion(mult = c(0.025, 0.055))) +
  labs(
    title = "Annual NO2 Levels in Sheffield",
    subtitle = "Monthly Average NO2 Levels by Year (2022-2025) WIth Months of Highest Variance Shaded", ,
    caption = "Data Source: Sheffield Air Quality Monitoring Network | Visualization: Student 250215478",
    x = NULL,
    y = "Concentration of NO2 (µg/m³)",
    color = "Year",
    shape = "Year"
  ) +
  standard_theme +
  theme(
    legend.position = "none"
  )

## Visualisation 4 ##
#Create heatmap comparing annual hourly NO2 levels from 2023-2025 to 2022
ggplot(annual_NO2_heatmap_comparison, aes(x = comparison, y = hour, fill = difference)) +
  geom_tile(color = "white", linewidth = 0.2) +
  geom_rect_pattern(
    data = peak_traffic_times,
    aes(
      xmin = -Inf, xmax = Inf, 
      ymin = ymin, ymax = ymax, 
      pattern = "Peak\nTraffic\nHours"
    ), 
    inherit.aes = FALSE,
    fill = NA,              
    colour = NA,            
    pattern_colour = "black",
    pattern_alpha = 0.3,
    pattern_density = 0.15,
    pattern_angle = 45,
    pattern_size = 0.8
  ) +
  scale_pattern_manual(
    name = NULL, 
    values = c("Peak\nTraffic\nHours" = "circle")
  ) +
  scale_fill_gradient(
    high = "#eff3ff",   
    low = "#08519c",  
    name = "NO2\nConcen-\ntration\nChange\n(µg/m³)"
  ) +
  guides(
    fill = guide_colorbar(order = 1),
    pattern = guide_legend(
      order = 2, 
      override.aes = list(fill = "white", color = "black")
    )
  ) + 
  scale_y_continuous(
    breaks = seq(0, 23, 2), 
    labels = function(x) sprintf("%02d:00", x),
    expand = c(0, 0)
  ) +
  scale_x_discrete(expand = c(0, 0)) +
  labs(
    title = "Comparison of Annual NO2 Levels in Sheffield (2023-2025 vs 2022)",
    subtitle = "Hourly NO2 Levels Compared to Hourly NO2 Levels in 2022 (Peak Traffic Times are Patterned)",
    caption = "Data Source: Sheffield Air Quality Monitoring Network | Visualization: Student 250215478",
    x = NULL,
    y = NULL
  ) +
  standard_theme +
  theme(
    legend.position = "right",
    legend.key.height = unit(1.5, "cm"),
    legend.key.width = unit(1, "cm"),
    legend.text = element_text(size = 14),
    legend.title = element_text(size = 14),
    panel.grid = element_blank(),
    plot.caption.position = "plot"
  )

## End of Script ##
