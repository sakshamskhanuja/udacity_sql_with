-- Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.
WITH table1 AS (SELECT r.name region, s.id rep_id, s.name rep, SUM(o.total_amt_usd) sales
                FROM region r
                JOIN sales_reps s
				ON r.id = s.region_id
                JOIN accounts a
                ON s.id = a.sales_rep_id
                JOIN orders o
                ON a.id = o.account_id
                GROUP BY 1, 2, 3
				ORDER BY 1, 4 DESC),
                
	 table2 AS (SELECT region, MAX(sales) max_sale
                FROM table1
                GROUP BY 1)

SELECT t1.rep, t1.region, t1.sales
FROM table1 t1
JOIN table2 t2
ON t1.region = t2.region AND t1.sales = t2.max_sale
ORDER BY 3 DESC;

-- For the region with the largest sales total_amt_usd, how many total orders were placed?
WITH table1 AS (SELECT r.name region, SUM(o.total_amt_usd) sales
                FROM region r
				JOIN sales_reps s
                ON r.id = s.region_id
                JOIN accounts a
                ON a.sales_rep_id = s.id
                JOIN orders o
                ON a.id = o.account_id
                GROUP BY 1
                ORDER BY 2 DESC
                LIMIT 1),
                
	table2 AS (SELECT region
			   FROM table1),
               
	table3 AS (SELECT r.name region, COUNT(o.id) order_num
			   FROM region r
			   JOIN sales_reps s
               ON r.id = s.region_id
               JOIN accounts a
               ON a.sales_rep_id = s.id
               JOIN orders o
               ON a.id = o.account_id
               GROUP BY 1
               ORDER BY 2 DESC)

SELECT t2.region, t3.order_num
FROM table2 t2
JOIN table3 t3
ON t2.region = t3.region;

/* How many accounts had more total purchases than the account name which has bought the most standard_qty paper
throughout their lifetime as a customer? */
WITH table1 AS (SELECT account_id, SUM(standard_qty), SUM(total) total
                FROM orders
                GROUP BY 1
                ORDER BY 2 DESC
                LIMIT 1),
	 
     table2 AS (SELECT account_id, SUM(total)
                FROM orders
                GROUP BY 1
                HAVING SUM(total) > (SELECT total
                                     FROM table1))

SELECT COUNT(*)
FROM table2;

/* For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, how many web_events
did they have for each channel? */
WITH table1 AS (SELECT account_id, SUM(total_amt_usd) sales
                FROM orders
                GROUP BY 1
                ORDER BY 2 DESC
                LIMIT 1),
	 
     table2 AS (SELECT account_id, channel, COUNT(*) num_of_web_events
                FROM web_events
                WHERE account_id = (SELECT account_id
                                    FROM table1)
				GROUP BY 1, 2
                ORDER BY 3 DESC)

SELECT a.name, table2.channel, table2.num_of_web_events
FROM table2
JOIN accounts a
ON a.id = table2.account_id;

-- What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?
WITH table1 AS (SELECT account_id, SUM(total_amt_usd) sales
               FROM orders
               GROUP BY 1
               ORDER BY 2 DESC
               LIMIT 10)

SELECT AVG(sales) lifetime_avg
FROM table1;

/* What is the lifetime average amount spent in terms of total_amt_usd, including only the companies that spent more
per order, on average, than the average of all orders. */
WITH table1 AS (SELECT AVG(total_amt_usd) avg_sales
				FROM orders),
	 
     table2 AS (SELECT account_id, AVG(total_amt_usd) avg_sales
                FROM orders
                GROUP BY 1
                HAVING AVG(total_amt_usd) > (SELECT avg_sales
                                             FROM table1)
	            ORDER BY 2 DESC)

SELECT AVG(avg_sales) lifetime_avg
FROM table2;