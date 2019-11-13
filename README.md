# Customer-Segmentation
A customer segmentation model based on a sample of retail data. Customers are split into the following segments: best, recent and worst. The model uses kmeans clustering to determine the segments.

## Folders:
* Input Folder: Contains two sample datasets - transactions.csv and customers.csv
* Query Folder: Presto SQL Query to create an aggregated dataset of features to feed into the model. The output of the query is customer_table.csv
* Model Folder: Jupyter Notebook containing the customer segmentation model & analysis. The input into the model is customer_table.csv


## Segments
![alt text](https://github.com/anubha820/Customer-Segmentation/blob/master/Model/clusters.png)
* Best Customers - They are the customers that have made the most purchases and spent the most (have the highest LTV). We can see that many of these customers have purchased multiple products.
* Worst Customers - All of these customers have made their last purchase over 6 months ago and haven't purchased as many products.
* Recent Transactors  - These customers are more recent customers, having made purchases in the last 6 months. They haven't purchased that much in terms of quantity and monetary value, but they have potential to purchase more.
