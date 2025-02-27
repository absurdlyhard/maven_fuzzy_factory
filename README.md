# Maven Fuzzy Factory E-Commerce Analysis

## Project Overview
This project is an in-depth analysis of the **Maven Fuzzy Factory** e-commerce website's sales performance using **MySQL**. The objective is to answer complex business questions related to sales, customer behavior, and product performance. The analysis is backed by SQL queries that extract valuable insights from the database.

## Database Schema
The **Maven Fuzzy Factory** database consists of multiple interconnected tables that track user sessions, orders, products, and refunds. Below is a brief description of the tables:

- **website_sessions**: Tracks user sessions on the website, including session source, campaign details, device type, and referrer information.
- **website_pageviews**: Stores page views within each session, capturing the URL and timestamp.
- **orders**: Contains transaction data, linking users to their purchases, including product details, item count, and pricing information.
- **products**: Holds information on the products available in the store.
- **order_items**: Breaks down orders into individual items, specifying whether they are the primary purchase and their associated costs.
- **order_item_refunds**: Tracks refunds for specific order items along with the refund amounts.

## Files in the Repository
- `Project_1.sql`: Contains SQL queries that analyze key sales metrics and customer behavior.
- `Project_2.sql`: Includes advanced queries to derive insights on revenue trends and product performance.
- `create_database.sql`: The database creation script is too large for GitHub. You can download it from [this link](https://drive.google.com/file/d/1l0mOucaI-bKIIQ16Cg-OgTP0NjSYXnsx/view?usp=drive_link).

## Performance Optimization Hints
To efficiently create and run queries on the **mavenfuzzyfactory** database, use the following settings to prepare the workbench on your machine:
```sql
-- 1) Adjust max packet size to allow large files
SET GLOBAL max_allowed_packet = 1073741824;

-- 2) Modify SQL mode for flexible query execution
SET GLOBAL SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES,ONLY_FULL_GROUP_BY';

-- 3) Increase timeout settings for longer queries
SET GLOBAL connect_timeout=28800;
SET GLOBAL wait_timeout=28800;
SET GLOBAL interactive_timeout=28800;
```

## Objective of the Analysis
This project aims to:
- **Understand website traffic patterns and conversion rates**: By analyzing session data, we can determine which marketing sources drive the most engaged users and the impact of different traffic sources on sales.
- **Analyze revenue trends and customer purchasing behavior**: The project examines order trends over time, including peak sales periods, average order values, and repeat customer behavior.
- **Identify high-performing products and refund trends**: We analyze product sales, customer preferences, and which products tend to have higher refund rates, helping optimize inventory and improve customer satisfaction.
- **Optimize marketing efforts based on session data**: By tracking UTM parameters and referrer data, we can identify the best-performing campaigns and devices used by customers, leading to better allocation of marketing budgets.
- **Evaluate the relationship between order items and refunds**: Understanding refund trends helps in identifying potential product or service issues and improving overall e-commerce operations.

## How to Use
1. Clone the repository and set up the **Maven Fuzzy Factory** database.
2. Run the provided SQL scripts in MySQL to extract insights.
3. Modify queries as needed to answer additional business questions.

---
This repository serves as a valuable resource for advanced e-commerce data analysis using SQL. Contributions and discussions are welcome!
