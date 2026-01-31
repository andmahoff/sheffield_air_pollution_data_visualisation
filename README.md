# sheffield_air_pollution_data_visualisation
Repository for my data science course IJC445 module project.

# Visualising how NO2 Levels Change With Time in Sheffield

### Introduction
Since the industrial revolution, rapid urbanization has dramatically increased levels of air pollution. Air pollution is a major public health issue associated with many health problems including asthma and lung cancer. Tt is estimated to account for around 29,000 to 43,000 deaths a year in the UK alone. Previous studies have shown that NO2 levels daily, weekly, and seasonal patterns in urban areas.
This project visualises daily, weekly, seasonal and annual NO2 levels in Sheffield for the years 2022-2025 to explore any time-based patterns that Nitrogen Dioxide ($NO_2$) levels may have in Sheffield. Better understanding of this topic can help predict when air pollution levels will be high in Sheffield.

### Research Questions
* **RQ1:** Which weather variables are most strongly correlated with air pollution levels in Sheffield?
* **RQ2.1:** To what extent can these weather variables predict air pollution levels in Sheffield?
* **RQ2.2:** Are multilinear regression models or random forest models better at predicting air pollution levels in Sheffield?

### Key Findings
* **Key Drivers:** Wind speed is by far the strongest predictor of NO2 levels in Sheffield followed by temperature and daylight duration. Higher wind speeds significantly reduce pollution.
<div align="center"><img width="607" height="388" alt="correlation table picture" src="https://github.com/user-attachments/assets/fbd1dc4d-8329-4d8d-9ea7-6a95a15b62b7" />
<div align="center">
    <i>Figure showing the correlation table found in this project between NO2 levels and weather variables in Sheffield.</i>
<div align="left">
    
* **Predictive power of weather data:** Weather data can predict NO2 levels in Sheffield fairly well. The multilinear regression model had an adjusted R squared value of 0.62 and relative prediction error of 29.1%. The random forest model had an OOB R squared value of 0.67 and relative prediction error of 27.7%.

* **Random Forest:** The random forest model performed better than the multilinear regression model. This is because many of the weather variables had non-linear relationships with NO2.

### The R Code
The analysis was performed using **R version 4.5.2**.
The files to run this project are in the [`sheffield_air_pollution_analysis`](https://github.com/andmahoff/sheffield_air_pollution_analysis/tree/main/sheffield_air_pollution_analysis) folder in this repository. The folder contains the subfolders:
* **`data/`**: This contains `air pollution complete.csv` and `weather data.csv` - the raw CSV files (air pollution and weather data).
* **`scripts/`**: This contains `full_project_script.R` (The full project script).

### Instructions for Downloading and Running the Project Code
1.  **Downloading the Project Files:**

    Download the files from the [`sheffield_air_pollution_analysis`](https://github.com/andmahoff/sheffield_air_pollution_analysis/tree/main/sheffield_air_pollution_analysis) folder and save them into the same folder that will be your working directory. If you decide to rename the files, remember to change the import filenames in the R script later on.
3.  **Open the R language supporting IDE:**

    Open the IDE in which you want to run the project R script. Remember to use R version 4.5.2
4.  **Install dependencies:**

    Run the following line in the R console to install the required packages (if you do not have them installed already):
    ```r
    install.packages(c("tidyverse", "janitor", "openair", "ranger", "broom", "zoo", "writexl", "correlation", "corrplot", "FSA", "car", "lmtest", "sandwich","relaimpo", "openair","forecast", "ranger", "pdp"))
    ```
5.  **Open the script and set the working directory:**

     Open `scripts/full_project_script.R` and set the working directory to the folder which contains the downloaded raw weather and air pollution data e.g.
     ```r
    setwd("c:\\Users\\andmahoff user\\Documents\\Folder with raw air pollution and weather data")
     ```
6.  **Run the Script:**

    Click **"Run All"** on your IDE.
