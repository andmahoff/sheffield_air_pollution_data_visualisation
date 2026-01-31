# sheffield_air_pollution_data_visualisation
Repository for my data science course IJC445 module project.

# Visualising how NO2 Levels Change With Time in Sheffield

### Introduction
Since the industrial revolution, rapid urbanization has dramatically increased levels of air pollution. Air pollution is a major public health issue associated with multiple health problems such as asthma and lung cancer and it is estimated to account for around 29,000 to 43,000 deaths a year in the UK alone. Previous studies have shown that NO2 levels follow daily, weekly, and seasonal patterns in urban areas.
This project visualises daily, weekly, seasonal and annual NO2 levels in Sheffield for the years 2022-2025 to explore any time-based patterns that Nitrogen Dioxide ($NO_2$) levels may have in Sheffield. Better understanding of this topic can help predict when air pollution levels will be high in Sheffield.

### Composite Visualisation
<img width="965" height="608" alt="Composite VIsualisation Image" src="https://github.com/user-attachments/assets/8994bbcb-998d-4a50-b672-385743677952" />
<div align="center">
    <i>Figure showing the composite visualisation created in this project to show how NO2 levels change with time in Sheffield.</i>
<div align="left">

### Research Questions
* **RQ1:** How do NO2 levels vary in Sheffield depending on the type of day?
* **RQ2:** How do NO2 levels vary depending on the month and season?
* **RQ3.1:** How do NO2 levels vary depending on the year?
* **RQ3.2:** How and where have NO2 levels changed over the years 2022-2025?

### Key Findings
* **Workweek NO2 Levels > Weekend NO2 Levels:** Workweek days have higher NO2 levels on average than Weekend days. NO2 hourly peaks for workweek days corresponded well with peak traffic hours in Sheffield. This provides evidence that NO2 levels are higher during the workweek due to increased road transport emissions.
    
* **NO2 Levels are Highest in the Winter:** Winter has the highest NO2 levels whilst Summer has the lowest NO2 levels in Sheffield. This is consistent with seasonal NO2 patterns found in other countries. NO2 levels are most likely higher in the Winter due to increased emissions from heating whilst they are lower in the Summer due to the increased breakdown of NO2 particles from photolysis and sunlight.

* **NO2 Levels are Decreasing:** NO2 levels have slowly reduced every year for the years 2022-2025. This is consistent with literature reports about NO2 levels in the UK.

* **Cause of Annual Decrease:** The greatest reductions in NO2 levels compared to 2022 have been mainly during peak traffic hours. Therefore, this provides evidence that the main cause of lower NO2 levels in Sheffield over the last years has been a reduction in emissions from road transportation.

### The R Code
The analysis was performed using **R version 4.5.2**.
The files to run this project are in the [`sheffield_air_pollution_data_visualisation`](https://github.com/andmahoff/sheffield_air_pollution_data_visualisation/tree/main/sheffield_air_pollution_data_visualisation) folder in this repository. The folder contains the subfolders:
* **`data/`**: This contains `air pollution data hourl.csv` - the raw CSV file for air pollution.
* **`scripts/`**: This contains `data visualisation full project script.R` (The full project script).
* * **`visualisations/`**: This contains `composite visualisation.png`, `visualisation 1.png`, `visualisation 2.png`, `visualisation 3.png`, `visualisation 4.png`   - composite visualisations as well as the four individual visualisations created in this project as png files.

### Instructions for Downloading and Running the Project Code
1.  **Downloading the Project Files:**

    Download the files from the [`sheffield_air_pollution_data_visualisation`](https://github.com/andmahoff/sheffield_air_pollution_data_visualisation/tree/main/sheffield_air_pollution_data_visualisation) folder and save them into the same folder that will be your working directory. If you decide to rename the files, remember to change the import filenames in the R script later on.
3.  **Open the R language supporting IDE:**

    Open the IDE in which you want to run the project R script. Remember to use R version 4.5.2
4.  **Install dependencies:**

    Run the following line in the R console to install the required packages (if you do not have them installed already):
    ```r
    install.packages(c("tidyverse", "janitor", "naniar", "lubridate", "ggpattern"))
    ```
5.  **Open the script and set the working directory:**

     Open `scripts/data_visualisafull_project_script.R` and set the working directory to the folder which contains the raw air pollution data e.g.
     ```r
    setwd("c:\\Users\\andmahoff user\\Documents\\Folder with raw air pollution data")
     ```
6.  **Run the Script:**

    Click **"Run All"** on your IDE.
