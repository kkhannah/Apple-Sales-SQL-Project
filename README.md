
# Apple Retail Sales SQL Project - Analyzing Millions of Sales Records


## Project Overview

This project showcases advanced SQL querying techniques by analyzing a dataset containing over 1 million rows of Apple retail sales records. The dataset provides insights into product performance, store operations, and warranty claims across various Apple retail locations globally.

This project aims to answer real-world business questions using SQL, covering sales trends, product demand, warranty claim patterns, and store performance. The analysis leverages SQL window functions, aggregations, and correlation techniques to extract meaningful insights.


## Entity Relationship Diagram (ERD)

The dataset follows a structured relational database schema, ensuring efficient querying and data integrity.

![ERD](https://github.com/kkhannah/Apple-Sales-SQL-Project/blob/main/ER%20Diagram/ER%20Diagram.png)


## Database Schema

The project uses five main tables:

1. **stores**: Contains information about Apple retail stores.
   - `store_id`: Unique identifier for each store.
   - `store_name`: Name of the store.
   - `city`: City where the store is located.
   - `country`: Country of the store.

2. **category**: Holds product category information.
   - `category_id`: Unique identifier for each product category.
   - `category_name`: Name of the category.

3. **products**: Details about Apple products.
   - `product_id`: Unique identifier for each product.
   - `product_name`: Name of the product.
   - `category_id`: References the category table.
   - `launch_date`: Date when the product was launched.
   - `price`: Price of the product.

4. **sales**: Stores sales transactions.
   - `sale_id`: Unique identifier for each sale.
   - `sale_date`: Date of the sale.
   - `store_id`: References the store table.
   - `product_id`: References the product table.
   - `quantity`: Number of units sold.

5. **warranty**: Contains information about warranty claims.
   - `claim_id`: Unique identifier for each warranty claim.
   - `claim_date`: Date the claim was made.
   - `sale_id`: References the sales table.
   - `repair_status`: Status of the warranty claim (e.g., Paid Repaired, Warranty Void).


## Objectives

The goal of this project is to conduct an exploratory data analysis (EDA) and answer key business-related questions using SQL. Below are some of the core analyses performed:

1. Count the number of stores in each country.

2. Calculate the total number of units sold by each store.

3. Identify the number of sales transactions that occurred in December 2023.

4. Determine which stores have never had a warranty claim filed.

5. Calculate the percentage of warranty claims marked as "Warranty Void".

6. Identify the store with the highest total units sold in the last year.

7. Count the number of unique products sold in the last year.

8. Find the average price of products in each category.

9. Determine how many warranty claims were filed in 2020.

10. Identify the best-selling day for each store based on the highest quantity sold.

11. Identify the least-selling product in each country for each year based on total units sold.

12. Calculate the number of warranty claims filed within 180 days of a product sale.

13. Determine the number of warranty claims filed for products launched in the last two years.

14. List the months in the last three years where sales exceeded 5,000 units in the USA.

15. Identify the product category with the most warranty claims filed in the last two years.

16. Calculate the percentage chance of receiving warranty claims after each purchase for each country.

17. Analyze the year-over-year growth ratio for each store.

18. Compute the correlation between product price and warranty claims for products sold in the last five years, segmented by price range.

19. Identify the store with the highest percentage of "Paid Repaired" claims relative to total claims filed.

20. Write a query to calculate the monthly running total of sales for each store over the past four years and compare trends over time.

21. Analyze product sales trends over time, segmenting them into key periods: from launch to 6 months, 6-12 months, 12-18 months, and beyond 18 months.


## Project Focus

This project emphasizes advanced SQL techniques, including:

- **Complex Joins and Aggregations**: Demonstrating the ability to perform complex SQL joins and aggregate data meaningfully.
- **Window Functions**: Using advanced window functions for running totals, growth analysis, and time-based queries.
- **Data Segmentation**: Analyzing data across different time frames to gain insights into product performance.
- **Correlation Analysis**: Applying SQL functions to determine relationships between variables, such as product price and warranty claims.
- **Real-World Problem Solving**: Answering business-related questions that reflect real-world scenarios faced by data analysts.


## Dataset Information

- **Size**: 1 million+ rows of sales data.
- **Time Period**: The data spans multiple years, allowing for long-term trend analysis.
- **Geographical Coverage**: Sales data from Apple stores across various countries.


## Conclusion

This project demonstrates how SQL can be leveraged to extract meaningful business insights from large datasets. The project utilises exploratory data analysis to uncover trends in sales, warranty claims, and product performance, helping businesses make data-driven decisions. By employing advanced SQL techniques such as window functions, complex joins, and correlation analysis, the analysis provides a comprehensive understanding of Apple’s retail sales performance across different regions and time periods.

---
