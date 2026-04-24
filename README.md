## Business Problem

An e-commerce business needs to understand sales performance, customer behavior, product performance, delivery efficiency, retention, and freight impact in order to make better business decisions. This project uses SQL to turn raw operational data into business insights that support revenue growth, customer retention, and operational improvement. 

## Dataset

This project is built on a **Brazilian e-commerce dataset (2023 sample data)** with four main tables: **customers, orders, products, and order_items**. The data also includes realistic quality issues such as missing customer references, duplicates, inconsistent nulls, and freight-cost variation, which makes the project feel closer to real business data. 

## Tools Used

* SQL
* SQLite / PostgreSQL compatible SQL
* GitHub for project documentation and version control

The repo is organized into `schema.sql`, `load_data.sql`, `data_quality.sql`, and `business_analysis.sql`, showing a full SQL workflow from database setup to insight generation. 

## Questions Answered

* How are sales trending month over month?
* Who are the highest-value customers?
* Which products and categories generate the most revenue?
* How efficient is the delivery process by state?
* What is the repeat purchase rate?
* Where are sales concentrated geographically?
* Where do customers drop off in the sales funnel?
* How do freight costs affect profitability?
* What is the estimated customer lifetime value?
* Which products are frequently bought together? 

## SQL Queries Used

This project uses:

* `JOIN`s across multiple tables
* `GROUP BY` and aggregations
* `CASE WHEN` for segmentation and flags
* `CTE`s for retention and CLV analysis
* Window functions like `RANK()`
* Date functions such as `STRFTIME()` and `JULIANDAY()`
* Data quality checks for orphaned records and duplicates
* Index creation for query performance improvement 

## Key Findings

* Sales trend analysis helps identify revenue movement over time.
* Customer segmentation highlights VIP, loyal, standard, and at-risk customers.
* Product and category analysis shows which items contribute most to revenue.
* Delivery analysis reveals state-level differences in shipping performance.
* Funnel analysis helps spot order drop-off between placement, approval, shipping, and delivery.
* Freight analysis shows where shipping costs may reduce profitability.
* Retention and CLV analysis help estimate long-term customer value. 

## Business Recommendations

* Focus retention campaigns on **at-risk** and **high-value** customers.
* Promote top-performing product categories more aggressively.
* Review logistics performance in slower-delivery regions.
* Monitor freight-heavy categories to protect margins.
* Use repeat purchase and CLV insights to improve customer loyalty strategy.
* Explore cross-sell opportunities from products frequently bought together. 
