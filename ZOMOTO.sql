
CREATE TABLE zomato(

RestaurantID INTEGER PRIMARY KEY,
RestaurantName VARCHAR(55),
CountryCode	 INTEGER,
City VARCHAR(25),
Address	VARCHAR(150),
Locality VARCHAR(55),
LocalityVerbose VARCHAR(65),
Cuisines VARCHAR(95),
Currency VARCHAR(35),
Has_Table_booking VARCHAR(4),
Has_Online_delivery	VARCHAR(4),
Is_delivering_now	VARCHAR(4),
Switch_to_order_menu VARCHAR(4),
Price_range	INTEGER,
Votes INTEGER,
Average_Cost_for_two INTEGER,
Rating NUMERIC(3,1)

);

ALTER TABLE ZOMATO 
ALTER COLUMN  RATING TYPE DECIMAL(3,1);

SELECT * FROM ZOMATO;

-- 1) RATING DISTRIBUTION AND TRENDS.
-- Average rating per city 
 SELECT city ,ROUND(AVG(rating),2)
 FROM zomato 
 GROUP BY city;

-- Average rating per price range.
 SELECT price_range ,ROUND(AVG(rating),2)
 FROM zomato 
 GROUP BY  price_range
 ORDER BY price_range;

--Cuisines with the highest/lowest average rating
SELECT Cuisines, MAX(rating) AS MAX_rating , COUNT(*) AS CTOTAL_ORDERS
FROM zomato
GROUP BY Cuisines
ORDER BY  MAX_rating DESC,CTOTAL_ORDERS DESC;

--Top 10 most voted and highly rated restaurants.
SELECT RestaurantName,votes,rating
FROM zomato
ORDER BY votes DESC
LIMIT  10;

--Overall rating distribution
SELECT 
  CASE 
    WHEN Rating BETWEEN 0 AND 1 THEN '0-1'
    WHEN Rating BETWEEN 1 AND 2 THEN '1-2'
    WHEN Rating BETWEEN 2 AND 3 THEN '2-3'
    WHEN Rating BETWEEN 3 AND 4 THEN '3-4'
    WHEN Rating BETWEEN 4 AND 5 THEN '4-5'
  END AS RATING_RANGE, 
  COUNT(*) AS count_per_range
FROM zomato
GROUP BY RATING_RANGE
ORDER BY RATING_RANGE;

--2) Rating-based Filtering
--Top-rated restaurants per city or locality.

SELECT RestaurantName,City, MAX(rating)  over(PARTITION BY city ) AS rating
FROM zomato;

--Top-rated restaurants offering online delivery or table booking
SELECT RestaurantName,City, Rating , Has_Online_delivery,Has_Table_booking
FROM zomato
WHERE Has_Online_delivery='Yes' AND Has_Table_booking='Yes'
ORDER BY rating DESC;

--Restaurants currently delivering with rating > 4.5.
SELECT RestaurantName,City, Rating,Is_delivering_now
FROM zomato
WHERE Is_delivering_now='Yes' AND Rating>=4.5;

--Top-rated restaurants for all price ranges.
SELECT RestaurantName ,Price_range,rank
FROM 
(SELECT RestaurantName ,Price_range,
DENSE_RANK() over(PARTITION BY Price_range ORDER BY rating ) AS rank
FROM zomato
ORDER BY Price_range DESC,rank )
WHERE rank <=3;

-- 3. Comparative Insights
--Compare average ratings between restaurants with and without table booking.
SELECT Has_Table_booking,ROUND(AVG(rating),2) AS AVERAGE_RATING
FROM zomato
GROUP BY  Has_Table_booking;

--Compare ratings for online delivery vs. no delivery.
SELECT Has_Online_delivery,ROUND(AVG(rating),2) AS AVERAGE_RATING
FROM zomato
GROUP BY  Has_Online_delivery;

--Top-Rated Restaurants (Rating > 4.5) Ranked by Cuisine Category
SELECT RestaurantName,City,Cuisines,rating,
DENSE_RANK() OVER(PARTITION BY Cuisines ORDER BY rating DESC) AS RANK
FROM zomato
WHERE rating >4.5;

--Compare ratings of restaurants with  Average Cost for two.
SELECT Average_Cost_for_two,ROUND(AVG(rating),2) AS RATING
FROM zomato
WHERE RATING>=4.5
GROUP BY Average_Cost_for_two
ORDER BY Average_Cost_for_two DESC;

--4. Group-Based Aggregations
--Average rating per cuisine type 

SELECT  cuisines,ROUND(AVG(rating ),2) AS AVERAGE_RATING,COUNT(*) AS COUNT
FROM zomato
GROUP BY cuisines
ORDER BY COUNT DESC,AVERAGE_RATING DESC;

--Locality-Wise Average Restaurant Ratings and Count (Sorted by Popularity).

SELECT Locality,ROUND(AVG(rating),2)AS AVG_RATING, COUNT(*) AS COUNT AS POPULARITY
FROM zomato
GROUP BY locality
ORDER BY POPULARITY DESC, AVG_RATING DESC;

-- city-wise rating leaderboard.
SELECT * FROM (
SELECT CITY,RestaurantName,rating , DENSE_RANK() OVER( PARTITION BY CITY ORDER BY RATING DESC) AS RANK
FROM zomato)
WHERE RANK <=3;

--Rating-based segmentation:Gold (4.5–5,)Silver (4–4.4,)Bronze (3–3.9),Low-rated (<3).
SELECT category , COUNT(*)
FROM (
SELECT rating,
  CASE 
    WHEN rating BETWEEN 4.5 AND 5 THEN 'GOLD'
    WHEN rating BETWEEN 4.0 AND 4.49 THEN 'SILVER'
    WHEN rating BETWEEN 3.0 AND 3.99 THEN 'BRONZE'
    WHEN rating < 3 THEN 'LOW_RATED'
    ELSE 'UNRATED'
  END AS category
FROM zomato)
GROUP BY CATEGORY
ORDER BY COUNT DESC;

--5. Outlier Detection
--Identify restaurants with unusually high rating but low votes(>50).
SELECT RestaurantName,Rating,Votes
FROM zomato
WHERE rating >= 4.5
  AND votes < 50
ORDER BY rating DESC, Votes ;

--Identify restaurants with many votes but low rating (potentially overrated/underrated).

SELECT RestaurantName,Rating,Votes
FROM zomato
WHERE rating <= 3
  AND votes > 500
ORDER BY Votes DESC, Rating ;

--Detect inconsistencies like high cost(>=2000) and very low rating(<=1).
SELECT RestaurantName,Average_Cost_for_two,Rating,votes
FROM zomato
WHERE Average_Cost_for_two >=2000 
AND rating <= 1
ORDER BY Average_Cost_for_two DESC,rating;

 --6. Predictive Insights 
 --Is there a relationship between cost and rating?
 SELECT Average_Cost_for_two,ROUND(AVG(Rating),2) AS AVERAGE_RATING
 FROM zomato
 GROUP BY  Average_Cost_for_two
 ORDER BY  AVERAGE_RATING DESC;

 --Which price range has the most consistent ratings?
SELECT 
  SUB.PRICE_RANGE,
  ROUND(AVG(Rating),2) AS avg_rating
FROM (
  SELECT  RestaurantName,Average_Cost_for_two,Rating
    ,
    CASE
      WHEN Average_Cost_for_two < 1000 THEN 'LOW COST'
      WHEN Average_Cost_for_two BETWEEN 1000 AND 5000 THEN 'MEDIUM COST'
      WHEN Average_Cost_for_two > 5000 THEN 'HIGH COST'
      ELSE 'NO COST'
    END AS PRICE_RANGE 
  FROM zomato
) AS SUB
GROUP BY SUB.PRICE_RANGE
ORDER BY avg_rating DESC;

--City having more average cost.

SELECT City,ROUND(AVG(Average_Cost_for_two),2) AS AVG_COST_FOR_TWO
FROM zomato
GROUP BY City 
ORDER BY AVG_COST_FOR_TWO DESC;



	
	
		








