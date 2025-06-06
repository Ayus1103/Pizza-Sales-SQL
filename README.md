# 🍕 Pizza Sales Analytics

This project contains a series of SQL queries designed to analyze various aspects of pizza sales. The queries illuminate everything from total orders and revenue to detailed breakdowns by pizza type, category, and order timing. The insights derived from these queries can help drive business decisions such as inventory management, promotional strategies, and operational planning.

---

## 📂 Database Schema

The analysis leverages the following tables:

- **orders**: Contains order details such as order ID, order date, and order time.
- **order_details**: Provides line-item details for each order, including the pizza ID and quantity.
- **pizzas**: Lists pizzas available with details about size, price, and foreign keys linking to pizza categories.
- **pizza_types**: Defines the pizza categories (or types) including names and other attributes such as category.

---

## 🔍 Queries and Insights

### 1. **Total Number of Orders Placed**

This query counts the total number of orders placed.

```sql
SELECT COUNT(order_id) AS total_orders
FROM orders;
```

*Insight*: Gauges overall business volume by providing the total count of orders.

---

### 2. **Total Revenue Generated from Pizza Sales**

This query calculates total revenue by summing the product of quantity and price for each pizza sold, with the revenue rounded for clarity.

```sql
SELECT ROUND(SUM(od.quantity * p.price)) AS total_sales
FROM order_details AS od
JOIN pizzas AS p ON p.pizza_id = od.pizza_id;
```

*Insight*: Helps measure the financial performance by indicating total sales revenue.

---

### 3. **Highest-Priced Pizza**

This query identifies the premium pizza offering by sorting pizzas in descending order of price and limiting the result to the top entry.

```sql
SELECT pizza_types.name, pizzas.price
FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;
```

*Insight*: Highlights the top-tier product offering, which can be used for premium marketing strategies.

---

### 4. **Most Common Pizza Size Ordered**

This query examines customer preferences by counting orders grouped by pizza size.

```sql
SELECT pizzas.size, COUNT(order_details.order_detail_id) AS orders_count
FROM pizzas
JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size;
```

*Insight*: Helps understand customer size preferences, informing portion or packaging strategies.

---

### 5. **Top 5 Most Ordered Pizza Types (by Quantity)**

This query aggregates the orders by pizza types and restricts the result to the five most popular ones.

```sql
SELECT pizza_types.name, SUM(order_details.quantity)
FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
LIMIT 5;
```

*Insight*: Identifies high-demand products, guiding inventory management and promotions.

---

### 6. **Percentage Contribution of Each Pizza Type to Total Revenue**

This advanced query calculates the revenue contribution percentage for each pizza category by dividing category-specific revenue by the total sales revenue.

```sql
SELECT 
    pizza_types.category,
    ROUND(
        SUM(order_details.quantity * pizzas.price) / (
            SELECT ROUND(SUM(order_details.quantity * pizzas.price), 2) AS total_sales
            FROM order_details
            JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id
        ) * 100, 2) AS revenue
FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;
```

*Insight*: Provides a clear breakdown of revenue by category, supporting targeted marketing and product prioritization.

---

### 7. **Cumulative Revenue Generated Over Time**

This query uses a window function to compute cumulative revenue over time, offering insights into sales trends.

```sql
SELECT order_date,
       SUM(revenue) OVER (ORDER BY order_date) AS cumm_revenue
FROM (
    SELECT orders.order_date, SUM(order_details.quantity * pizzas.price) AS revenue
    FROM order_details 
    JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
    JOIN orders ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date
) AS sales;
```

*Insight*: Tracks sales growth over time, which is useful for time-series analysis and forecasting.

---

### 8. **Top 3 Most Ordered Pizza Types Based on Revenue for Each Category**

This query ranks pizzas by revenue within each category and selects the top three from each group using window functions.

```sql
SELECT name, revenue
FROM (
    SELECT category, name, revenue,
           RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn
    FROM (
        SELECT pizza_types.category,
               pizza_types.name,
               ((order_details.quantity) * pizzas.price) AS revenue
        FROM pizza_types
        JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
        GROUP BY pizza_types.category, pizza_types.name
    ) AS a
) AS b
WHERE rn <= 3;
```

*Insight*: Offers a granular view of which products drive revenue in each category, aiding category-specific strategies.

---

### 9. **Total Quantity of Each Pizza Category Ordered**

This query aggregates the total number of pizzas ordered by each category.

```sql
SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM pizza_types
JOIN pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;
```

*Insight*: Assesses overall demand by category, which is essential for supply chain and menu optimization.

---

### 10. **Distribution of Orders by Hour of the Day**

This query extracts the hour from the order time to count orders per hour.

```sql
SELECT HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM orders
GROUP BY HOUR(order_time);
```

*Insight*: Reveals peak operating hours, guiding staffing and operational decisions.

---

### 11. **Category-wise Distribution of Pizzas**

This query groups the number of pizza types available by category.

```sql
SELECT category, COUNT(name)
FROM pizza_types
GROUP BY category;
```

*Insight*: Provides an overview of the menu composition by category.

---

### 12. **Average Number of Pizzas Ordered Per Day**

This query calculates the daily average pizzas ordered by aggregating orders on a per-day basis.

```sql
SELECT ROUND(AVG(quantity), 0) AS avg_pizza_order_per_day
FROM (
    SELECT orders.order_date, SUM(order_details.quantity) AS quantity
    FROM orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date
) AS order_quantity;
```

*Insight*: Helps assess daily consumption trends and operational consistency.

---

### 13. **Top 3 Most Ordered Pizza Types Based on Revenue Overall**

This query aggregates the revenue for each pizza type and returns the top three based on overall revenue.

```sql
SELECT 
    pizza_types.name,
    ROUND(SUM(order_details.quantity * pizzas.price), 0) AS revenue
FROM pizza_types
JOIN pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;
```

*Insight*: Pinpoints the best revenue-generating pizza options to guide strategic investment and promotion.

---

## 🚀 Conclusion

This comprehensive analysis using SQL provides valuable insights into order volume, revenue distribution, popular pizza sizes and types, and timing of orders. The queries enable stakeholders to understand both macro-level trends and granular details that can drive informed business decisions—from managing resources to optimizing the menu.

For further exploration, consider integrating these queries into a visualization tool or dashboard to monitor trends in real time. Additionally, expanding the analysis to include customer demographics and seasonal patterns could yield even deeper insights into market behavior.

--- 

Feel free to tailor the README to match your project’s requirements and add any additional documentation that might aid in understanding the business context or technical details.

Happy querying!

- Basic Queries: Simple aggregations with COUNT(), SUM(), JOIN
- Intermediate Queries: Time-based and category-wise analyses
- Advanced Queries: Percentage revenue calculation, ranking functions, and cumulative revenue tracking
