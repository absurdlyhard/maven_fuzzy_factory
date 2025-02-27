/*
1. Gsearch seems to be the biggest driver of our business. Could you pull monthly trends for gsearch sessions
and orders so that we can showcase the growth there?
*/

SELECT
	YEAR(website_sessions.created_at) AS yr,
    MONTH(website_sessions.created_at) AS mo,
    -- MIN(DATE(orders.created_at)) AS start_of_the_month,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT order_id) AS monthly_orders,
    COUNT(DISTINCT order_id) / COUNT(DISTINCT website_sessions.website_session_id) * 100 AS conversion_rate_percent
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-11-27' -- time of receiving the request
	AND utm_source = 'gsearch'
GROUP BY 1, 2;


/*
2. Next, it would be great to see a similar monthly trend for Gsearch, but this time splitting out nonbrand and
brand campaigns separately. I am wondering if brand is picking up at all. If so, this is a good story to tell.
*/

SELECT
	YEAR(website_sessions.created_at) AS yr,
    MONTH(website_sessions.created_at) AS mo,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS nonbrand_sessions,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS nonbrand_orders,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END) AS brand_sessions,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) brand_orders
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-11-27' -- time of receiving the request
	AND utm_source = 'gsearch'
GROUP BY 
	1, 2;

/*
3. While we're on Gsearch, could you dive into nonbrand, and pull monthly sessions and orders split by device
type? I want to flex our analytical muscles a little and show the board we really know our traffic sources.
*/

SELECT
	YEAR(website_sessions.created_at) AS yr,
    MONTH(website_sessions.created_at) AS mo,
    COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_sessions.website_session_id ELSE NULL END) AS desktop_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN orders.order_id ELSE NULL END) desktop_orders,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END) AS mobile_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN orders.order_id ELSE NULL END) AS mobile_orders
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-11-27' -- time of receiving the request
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY 
	1, 2;

/*
4. I'm worried that one of our more pessimistic board members may be concerned about the large % of traffic from
Gsearch. Can you pull monthly trends for Gsearch, alongside monthly trends for each of our other channels?
*/

SELECT DISTINCT
	utm_source,
    utm_campaign,
    http_referer
FROM website_sessions
WHERE
	created_at < '2012-11-27'; -- time of receiving the request
    
    
SELECT
	YEAR(website_sessions.created_at) AS yr,
    MONTH(website_sessions.created_at) AS mo,
    COUNT(DISTINCT website_sessions.website_session_id) AS all_sessions,
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN website_session_id ELSE NULL END) AS gsearch_paid_sessions,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN website_session_id ELSE NULL END) AS bsearch_paid_sessions,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN website_session_id ELSE NULL END) AS organic_search_sessions,
	COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_session_id ELSE NULL END) AS direct_type_in_sessions
FROM website_sessions
WHERE website_sessions.created_at < '2012-11-27' -- time of receiving the request
GROUP BY 
	1, 2;


/*
5. I'd like to tell the story of our website performance improvements over the course of the first 8 months.
Could you pull session to order conversion rates, by month?
*/

SELECT
	YEAR(website_sessions.created_at) AS yr,
    MONTH(website_sessions.created_at) AS mo,
    COUNT(DISTINCT website_sessions.website_session_id) AS all_sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    ROUND(COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) * 100, 2) AS conversion_percent
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-11-27' -- time of receiving the request
GROUP BY 
	1, 2;

/*
6. For the gsearch lander test, please estimate the revenue that test earned us (Hint: Look at the increase in CVR
from the test (Jun 19 - Jul 28), and use nonbrand sessions and revenue since then to calculate incremental value)
*/

-- 1) we need to know when (or by which pageview_id) the test was started:
SELECT
	MIN(website_pageview_id) AS min_pageview_id,
    MIN(created_at) AS start_of_the_test
FROM website_pageviews
WHERE pageview_url = '/lander-1';


-- 2) then we need to find the first (or minimum)npageview id for each session:
-- DROP TEMPORARY TABLE IF EXISTS first_test_pageviews;
CREATE TEMPORARY TABLE first_test_pageviews
SELECT
	website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM website_pageviews
	INNER JOIN website_sessions
		ON website_pageviews.website_session_id = website_sessions.website_session_id
        AND website_sessions.created_at < '2012-07-28' -- time of receiving the request
        AND website_pageviews.website_pageview_id >= 23504 -- from the result of the query above
        AND utm_campaign = 'nonbrand'
        AND utm_source = 'gsearch'
GROUP BY 1;

SELECT * FROM first_test_pageviews; -- Q/A only


-- 3) here we need to find the landing page for each web session:
-- DROP TEMPORARY TABLE IF EXISTS landing_pages;
CREATE TEMPORARY TABLE landing_pages
SELECT
	first_test_pageviews.website_session_id,
    pageview_url AS landing_page
FROM first_test_pageviews
	LEFT JOIN website_pageviews
		ON first_test_pageviews.website_session_id = website_pageviews.website_session_id
WHERE pageview_url IN ('/home', '/lander-1');

SELECT * FROM landing_pages; -- Q/A only


-- 4) we need to now connect: the result above to the orders
-- DROP TEMPORARY TABLE IF EXISTS sessions_w_orders;
CREATE TEMPORARY TABLE sessions_w_orders
SELECT
	landing_pages.website_session_id,
    landing_page,
    order_id
FROM landing_pages
	LEFT JOIN orders
		ON landing_pages.website_session_id = orders.website_session_id;
        
SELECT * FROM sessions_w_orders; -- Q/A only


-- 5) now it's time to see the differnce in conversion rates of landing pages:
SELECT
	landing_page,
	COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT order_id) / COUNT(DISTINCT website_session_id) AS cvr
FROM sessions_w_orders
GROUP BY 1;

-- the preceding query shows that:
-- /home cvr = 0.0318 and /lander-1 cvr = 0.0406
-- hence the differnce is 0.0088

-- 6) here, we have to find the most recent gsearch nonbrand trafic which was directed to /home:
SELECT
	MAX(website_sessions.website_session_id) AS last_home_pageview
FROM website_pageviews
	LEFT JOIN website_sessions
		ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand'
    AND pageview_url = '/home'
    AND website_sessions.created_at < '2012-11-27'; -- from the time of the request

-- based on the above query, the most recent gsearch nonbrand trafic directed to /home is website_session_id = 17145

SELECT
	COUNT(DISTINCT website_session_id) AS sessions_since_test
FROM website_sessions
WHERE utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand'
    AND website_session_id > 17145 -- last /home session
    AND created_at < '2012-11-27';

-- according to above, number of all session since the completion of test is 22972
-- by considering the increment of changing the landing test (0.0088) and multiplying that by the number of session (22972)
-- we can deduce approximately 202 more orders since 2012-07-29 were made (roughly 50 more orders per month) 


/*
7. For the landing page test you analyzed previously, it would be great to show a full conversion funnel from each
of the two pages to orders. You can use the same time period you analyzed last time (Jun 19 - Jul 28).
*/

-- here the solution is to first find all pageviews in the requested timeframe
-- then for each session_id we need to collect all the pageviews and flag them with 1/0
-- then these flags will help us to track each session_id from top to the bottom of conversion funnel

SELECT DISTINCT pageview_url FROM website_pageviews WHERE created_at BETWEEN '2012-06-19' AND '2012-07-28';

DROP TEMPORARY TABLE IF EXISTS flags;
CREATE TEMPORARY TABLE flags
SELECT
		website_session_id,
        pageview_url,
        CASE WHEN pageview_url='/home' THEN 1 ELSE 0 END AS home_flag,
        CASE WHEN pageview_url='/lander-1' THEN 1 ELSE 0 END AS lander_flag,
        CASE WHEN pageview_url='/products' THEN 1 ELSE 0 END AS products_flag,
        CASE WHEN pageview_url='/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_flag,
        CASE WHEN pageview_url='/cart' THEN 1 ELSE 0 END AS cart_flag,
        CASE WHEN pageview_url='/shipping' THEN 1 ELSE 0 END AS shipping_flag,
        CASE WHEN pageview_url='/billing' THEN 1 ELSE 0 END AS billing_flag,
        CASE WHEN pageview_url='/thank-you-for-your-order' THEN 1 ELSE 0 END AS thank_you_flag
	FROM (
SELECT
	website_pageviews.website_session_id,
    pageview_url
FROM website_pageviews
	LEFT JOIN website_sessions
		ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at BETWEEN '2012-06-19' AND '2012-07-28'
	AND utm_campaign = 'nonbrand'
    AND utm_source = 'gsearch'
    AND pageview_url IN
    ('/home', '/lander-1', '/products', '/the-original-mr-fuzzy', '/cart',
    '/shipping', '/billing', '/thank-you-for-your-order')
    ) AS sessions_and_views;
    
SELECT * FROM flags;

DROP TEMPORARY TABLE IF EXISTS flags_2;    
CREATE TEMPORARY TABLE flags_2    
SELECT
	website_session_id,
    MAX(home_flag) AS home_flag2,
    MAX(lander_flag) AS lander_flag2,
    MAX(products_flag) AS product_flag2,
    MAX(mrfuzzy_flag) AS mrfuzzy_flag2,
    MAX(cart_flag) AS cart_flag2,
    MAX(shipping_flag) AS shipping_flag2,
    MAX(billing_flag) AS billing_flag2,
    MAX(thank_you_flag) AS thank_you_flag2
FROM flags
GROUP BY 1;

SELECT * FROM flags_2;

SELECT
	CASE
		WHEN home_flag2 = 1 then '/home'
		WHEN lander_flag2 = 1 then '/lander-1'
        ELSE 'something must be wrong!'
	END AS landing_page,
    COUNT(website_session_id) AS sessions,
    COUNT(CASE WHEN product_flag2=1 THEN 1 ELSE NULL END) AS to_products,
    COUNT(CASE WHEN mrfuzzy_flag2=1 THEN 1 ELSE NULL END) AS to_mrfuzzy,
    COUNT(CASE WHEN cart_flag2=1 THEN 1 ELSE NULL END) AS to_cart,
    COUNT(CASE WHEN shipping_flag2=1 THEN 1 ELSE NULL END) AS to_shipping,
    COUNT(CASE WHEN billing_flag2=1 THEN 1 ELSE NULL END) AS to_billing,
    COUNT(CASE WHEN thank_you_flag2=1 THEN 1 ELSE NULL END) AS to_thankyou
FROM flags_2
GROUP BY 1
ORDER BY 1;

-- the above table could be converted easily to clickthrough rates by dividing the number of each step by its preceding

/*
8. I'd love for you to quantify the impact of our billing test, as well. Please analyze the lift generated from the test
(Sep 10 - Nov 10), in terms of revenue per billing page session, and then pull the number of billing page sessions
for the past month to understand monthly impact.
*/

-- by joining website_pageviews and orders tables to each other,
-- and then aggregating on billing pages, we get the requested revenue per billing page

SELECT
	pageview_url,
    COUNT(DISTINCT website_session_id) AS sessions,
    SUM(price_usd) AS total_revenue,
    SUM(price_usd)/COUNT(DISTINCT website_session_id) AS revenue_per_billing_page
FROM(
SELECT
	website_pageviews.website_session_id,
    pageview_url,
    price_usd
FROM website_pageviews
	LEFT JOIN orders
		ON website_pageviews.website_session_id = orders.website_session_id
WHERE website_pageviews.created_at BETWEEN '2012-09-10' AND '2012-11-10'
	AND pageview_url IN ('/billing', '/billing-2')
) AS pageview_and_orders
GROUP BY 1;

-- based on the query above:
-- the new billing page lifted revenue per billing page seen from 22.83 usd to 31.34 usd
-- so, the lift is 8.51 usd per billing page view

SELECT
	COUNT(website_session_id) AS billing_sessions_in_past_month
FROM website_pageviews
WHERE website_pageviews.created_at BETWEEN '2012-10-27' AND '2012-11-27'
	AND pageview_url IN ('/billing', '/billing-2');
    
-- the preceding query shows 1193 billing sessions in past month
-- by considering 8.51 usd lift per session,
-- the monthly impact of the test is equal to 10,160 usd