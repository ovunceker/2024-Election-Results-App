# Description of the App

## Data Collecction
In this project, I collected data of the votes from two different sources. The excel file **oylar .xlsx** is obtained from [Sözcü News](https://secim.sozcu.com.tr/secim2024mart31), 
Turkish news website. This file contains the winner party in each province and the percentage of votes this party obtained in this province. Whereas the second file
**province_votes.xlsx** is obtained from [Hürriyet News](https://secim.hurriyet.com.tr/31-mart-2024-yerel-secimleri/secim-sonuclari/), another Turkish news website. This file contains
more detailed results for each province. Specifically, it shows the candidates' names and the number of votes each party collected in this province. 

## App
You can see [this link](https://ovunceker.shinyapps.io/Election-Results/) for the app of this project. This app first demonstrates us a **plotly** graph, where you can hover around 
Turkey's provinces and see which party won with how much percentage in each state. Also, if you want to see more detailed results for each province, you can just click on the province
and see the names of candidates and number of votes for each party in clicked province.

## Technical Details
In order to draw Turkey's map we used **tr.json** file obtained from [this link](https://simplemaps.com/gis/country/tr). This file contains the borders of Turkey and its provinces. To
match the names of provinces in the two different files, namely **tr.json** and **oylar .xlsx**, we had to do some preprocessing which also included some manual changes. We also applied some preprocessing to the file **province_votes.xlsx** so that number of votes are correct and non-special words are all English. The rest was about trying to figure out how to make **shiny app** and **plotly** map as presentable as possible. 
