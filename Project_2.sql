/*
1- First, I'd like to show our volume growth. Can you pull overall session and order volume, trended by quarter
for the life of the business? Since the most recent quarter is incomplete, you can decide how to handle it.
*/

SELECT
	MAX(website_sessions.created_at)
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
;

-- since the last session doesn't complete a quarter and a fair comparison cannot be achieved, I would prefer to drop all 2015 sessions.

SELECT
	YEAR(website_sessions.created_at) AS yr,
    QUARTER(website_sessions.created_at) AS qtr,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT order_id) AS orders
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2015-01-01'
GROUP BY 1, 2
ORDER BY 1, 2
;


/*
2- Next, let's showcase all of our efficiency improvements. I would love to show quarterly figures since we
launched, for session-to-order conversion rate, revenue per order, and revenue per session.
*/

SELECT
	YEAR(website_sessions.created_at) AS yr,
    QUARTER(website_sessions.created_at) AS qtr,
    -- COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    -- COUNT(DISTINCT order_id) AS orders,
    ROUND(COUNT(DISTINCT order_id)/COUNT(DISTINCT website_sessions.website_session_id), 2) AS conv_rate,
    ROUND(SUM(price_usd)/COUNT(DISTINCT order_id), 2) AS revenue_per_order,
    ROUND(SUM(price_usd)/COUNT(DISTINCT website_sessions.website_session_id), 2) AS revenue_per_session
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2015-01-01'
GROUP BY 1, 2
ORDER BY 1, 2
;


/*
3- I'd like to show how we've grown specific channels. Could you pull a quarterly view of orders from Gsearch
nonbrand, Bsearch nonbrand, brand search overall, organic search, and direct type-in?
*/

-- to find out all possible sources, below query must be run
SELECT DISTINCT
	utm_source,
    utm_campaign,
    http_referer
FROM website_sessions
WHERE website_sessions.created_at < '2015-01-01';

SELECT
	YEAR(website_sessions.created_at) AS yr,
    QUARTER(website_sessions.created_at) AS qtr,
    -- COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT CASE WHEN utm_source='gsearch' AND utm_campaign='nonbrand' THEN order_id ELSE NULL END) AS gsearch_nonbrand,
    COUNT(DISTINCT CASE WHEN utm_source='bsearch' AND utm_campaign='nonbrand' THEN order_id ELSE NULL END) AS bsearch_nonbrand,
    COUNT(DISTINCT CASE WHEN utm_campaign='brand' THEN order_id ELSE NULL END) AS brand_search,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN order_id ELSE NULL END) AS org_search,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN order_id ELSE NULL END) AS direct_type_in
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2015-01-01'
GROUP BY 1, 2
ORDER BY 1, 2
;


/*
4- Next, let's show the overall session-to-order conversion rate trends for those same channels, by quarter.
Please also make a note of any periods where we made major improvements or optimizations.
*/

SELECT
	YEAR(website_sessions.created_at) AS yr,
    QUARTER(website_sessions.created_at) AS qtr,
    -- COUNT(DISTINCT website_sessions.website_session_id),
    -- COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT CASE WHEN utm_source='gsearch' AND utm_campaign='nonbrand' THEN order_id ELSE NULL END)/
		COUNT(DISTINCT CASE WHEN utm_source='gsearch' AND utm_campaign='nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS gsearch_nonbrand_cvr,
    COUNT(DISTINCT CASE WHEN utm_source='bsearch' AND utm_campaign='nonbrand' THEN order_id ELSE NULL END)/
		COUNT(DISTINCT CASE WHEN utm_source='bsearch' AND utm_campaign='nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS bsearch_nonbrand_cvr,
    COUNT(DISTINCT CASE WHEN utm_campaign='brand' THEN order_id ELSE NULL END)/
		COUNT(DISTINCT CASE WHEN utm_campaign='brand' THEN website_sessions.website_session_id ELSE NULL END) AS brand_search_cvr,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN order_id ELSE NULL END)/
		COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) AS org_search_cvr,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN order_id ELSE NULL END)/
		COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END) AS direct_type_in_cvr
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2015-01-01'
GROUP BY 1, 2
ORDER BY 1, 2
;


/*
5- We've come a long way since the days of selling a single product. Let's pull monthly trending for revenue
and margin by product, along with total sales and revenue. Note anything you notice about seasonality.
*/

SELECT
	YEAR(created_at) AS yr,
    MONTH(created_at) AS mnth,
    SUM(CASE WHEN product_id=1 THEN price_usd ELSE NULL END) AS mrfuzzy_rev,
    SUM(CASE WHEN product_id=1 THEN price_usd-cogs_usd ELSE NULL END) AS mrfuzzy_margin,
    SUM(CASE WHEN product_id=2 THEN price_usd ELSE NULL END) AS lovebear_revenue,
    SUM(CASE WHEN product_id=2 THEN price_usd-cogs_usd ELSE NULL END) AS lovebear_margin,
    SUM(CASE WHEN product_id=3 THEN price_usd ELSE NULL END) AS birthdaybear_revenue,
    SUM(CASE WHEN product_id=3 THEN price_usd-cogs_usd ELSE NULL END) AS birthdaybear_margin,
    SUM(CASE WHEN product_id=4 THEN price_usd ELSE NULL END) AS minibear_revenue,
    SUM(CASE WHEN product_id=4 THEN price_usd-cogs_usd ELSE NULL END) AS minibear_margin,
    -- COUNT(DISTINCT order_id) AS total_sales,
    SUM(price_usd) AS total_revenue,
    SUM(price_usd-cogs_usd) AS total_margin
FROM order_items
GROUP BY 1, 2
ORDER BY 1, 2
;


/*
6- Let's dive deeper into the impact of introducing new products. Please pull monthly sessions to the /products
page, and show how the % of those sessions clicking through another page has changed over time, along with
a view of how conversion from /products to placing an order has improved.
*/

DROP TEMPORARY TABLE IF EXISTS only_products_sessions;
CREATE TEMPORARY TABLE only_products_sessions
SELECT
	website_session_id,
    created_at,
    website_pageview_id,
    pageview_url
FROM website_pageviews
WHERE website_pageviews.pageview_url = '/products' 
;

SELECT * FROM only_products_sessions;

DROP TEMPORARY TABLE IF EXISTS after_products_sessions;
CREATE TEMPORARY TABLE after_products_sessions
SELECT
	website_pageviews.website_session_id,
    MIN(website_pageviews.created_at) AS next_page_created_at
FROM website_pageviews
	INNER JOIN only_products_sessions
		ON only_products_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.created_at > only_products_sessions.created_at
GROUP BY website_pageviews.website_session_id
;

SELECT * FROM after_products_sessions;

SELECT
	YEAR(website_pageviews.created_at) AS yr,
    MONTH(website_pageviews.created_at) AS mnth,
    COUNT(DISTINCT website_pageviews.website_session_id) AS product_page_sessions,
    COUNT(DISTINCT after_products_sessions.website_session_id) AS clicked_to_next_page,
    COUNT(DISTINCT after_products_sessions.website_session_id)/
		COUNT(DISTINCT website_pageviews.website_session_id) AS clickthrough_rate,
	COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT order_id)/COUNT(DISTINCT website_pageviews.website_session_id) AS product_to_order_rate
FROM website_pageviews
	LEFT JOIN after_products_sessions
		ON after_products_sessions.website_session_id = website_pageviews.website_session_id
	LEFT JOIN orders
		ON orders.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.pageview_url = '/products'
GROUP BY 1, 2
ORDER BY 1, 2
;


/*
7- We made our 4th product available as a primary product on December 05, 2014 (it was previously only a cross-sell
item). Could you please pull sales data since then, and show how well each product cross-sells from one another?
*/

DROP TEMPORARY TABLE IF EXISTS multiple_products_orders;
CREATE TEMPORARY TABLE multiple_products_orders
SELECT
	order_items.order_id,
    primary_product_id,
    product_id
FROM order_items
	LEFT JOIN orders
		ON order_items.order_id = orders.order_id
WHERE order_items.created_at > '2014-12-05'
	AND is_primary_item = 0
;

SELECT * FROM multiple_products_orders;

SELECT
	orders.primary_product_id,
    COUNT(DISTINCT orders.order_id) AS orders,
    -- SUM(orders.price_usd) AS revenue,
    -- SUM(orders.price_usd - orders.cogs_usd) AS profit,
    COUNT(DISTINCT CASE WHEN multiple_products_orders.product_id=1 THEN multiple_products_orders.order_id ELSE NULL END) AS p1_sell,
    COUNT(DISTINCT CASE WHEN multiple_products_orders.product_id=2 THEN multiple_products_orders.order_id ELSE NULL END) AS p2_xsell,
    COUNT(DISTINCT CASE WHEN multiple_products_orders.product_id=3 THEN multiple_products_orders.order_id ELSE NULL END) AS p3_xsell,
    COUNT(DISTINCT CASE WHEN multiple_products_orders.product_id=4 THEN multiple_products_orders.order_id ELSE NULL END) AS p4_xsell,
    COUNT(DISTINCT CASE WHEN multiple_products_orders.product_id=1 THEN multiple_products_orders.order_id ELSE NULL END)/
		COUNT(DISTINCT orders.order_id) AS p1_xsell_rt,
	COUNT(DISTINCT CASE WHEN multiple_products_orders.product_id=2 THEN multiple_products_orders.order_id ELSE NULL END)/
		COUNT(DISTINCT orders.order_id) AS p2_xsell_rt,
	COUNT(DISTINCT CASE WHEN multiple_products_orders.product_id=3 THEN multiple_products_orders.order_id ELSE NULL END)/
		COUNT(DISTINCT orders.order_id) AS p3_xsell_rt,
	COUNT(DISTINCT CASE WHEN multiple_products_orders.product_id=4 THEN multiple_products_orders.order_id ELSE NULL END)/
		COUNT(DISTINCT orders.order_id) AS p4_xsell_rt
FROM order_items
	LEFT JOIN orders
		ON order_items.order_id = orders.order_id
	LEFT JOIN multiple_products_orders
		ON order_items.order_id = multiple_products_orders.order_id
WHERE order_items.created_at > '2014-12-05'
GROUP BY 1
;

/*
8- In addition to telling investors about what we've already achieved, let's show them that we still have plenty of
gas in the tank. Based on all the analysis you've done, could you share some recommendations and
opportunities for us going forward? No right or wrong answer here - I'd just like to hear your perspective!
*/

 -- 1) Having more low-price products can increase cross-selling and eventually the overal profit.
 -- 2) More analysis can be done on the effect of social media campaigns on sales.
 -- 3) An in-depth analysis on users and calculating churn rate to decide where the promotions should be placed.
 -- 4) Adding insightfull visualizations using Excel/PowerBI/Python/Tableau can be incorporated
 --    into the existing alnalysis in order to help stakeholders in their business decisions.
 -- 5) More investigations on refund items can be helpful to mitigate the probable losses from this area. 


