-- Query 1: Retrieve the top 10 drivers, total_ratings, average ratings, driver's age, no of driving years experienced, car brand, car manufactured age
-- based on their total ratings and average ratings in descending order for dangerous safety risks
WITH DriverSafety AS (
	SELECT
		cd.driver_id, 
		cd.driver_name,
		SUM(driver_rating) AS total_ratings,
		CAST(AVG(driver_rating) AS decimal(10,2)) AS average_ratings,
		cd.car_brand,
		cd.No_of_Years_driving_exp AS No_of_Driving_Yrs_Exp,
		DATEDIFF(YEAR, CONVERT(DATE,data_of_birth, 101), GETDATE()) AS age_of_driver,
		(YEAR(GETDATE())-car_model_year) AS age_of_car,
		sl.label
	FROM Cab_Driver AS cd
	JOIN Safety_Labels AS sl ON cd.driver_id = sl.driver_id
	GROUP BY 
		cd.driver_id, 
		cd.driver_name, 
		cd.car_brand,
		cd.No_of_Years_driving_exp,
		DATEDIFF(YEAR, CONVERT(DATE,data_of_birth, 101), GETDATE()),
		YEAR(GETDATE())-car_model_year, 
		sl.label
)

SELECT TOP 10
	driver_name,
	total_ratings,
	average_ratings,
	age_of_driver,
	No_of_Driving_Yrs_Exp,
	car_brand,
	age_of_car
FROM DriverSafety
WHERE label = 1 AND No_of_Driving_Yrs_Exp <= 10
ORDER BY total_ratings DESC, average_ratings DESC;

-- Query 2: Bins the drivers according to average distance and obtain the average ratings, average counts of unsafe trips and rate of unsafe trips
WITH DriverTripData AS (
	SELECT
		d.driver_name AS driver_name,
		AVG(s.second * s.speed) AS avg_distance,
		CAST(SUM(sa.label) AS Float)/CAST(COUNT(sa.label) AS Float)*100 AS rate_of_unsafe_trips,
		SUM(sa.label) AS label_counts,
		AVG(d.driver_rating) AS driver_rating
	FROM Sensor_Data s
	JOIN Safety_Labels sa ON sa.bookingID = s.bookingID
	JOIN Cab_Driver d ON sa.driver_id = d.driver_id
	WHERE s.second * s. speed > 0
	GROUP BY d.driver_name, d.driver_id
)

SELECT 
	CASE
		WHEN avg_distance < 5000 THEN 'Group 1. Less than 5,000'
		WHEN avg_distance >=5000 AND avg_distance<=7000 THEN 'Group 2. 5,000 to 7,000'
		WHEN avg_distance >=7000 AND avg_distance<=9000 THEN 'Group 3. 7,000 to 9,000'
		ELSE 'Group 4. Greater than 9,000'
	END AS 'Distance Group',
	CAST(AVG(rate_of_unsafe_trips) AS decimal(4,2)) AS "Rate of Unsafe Trips (%)",
	AVG(label_counts) AS "Average Counts of Unsafe Trips",
	CAST(AVG(driver_rating) AS decimal(4,2)) AS "Average Driver Rating"
FROM DriverTripData
GROUP BY CASE
		WHEN avg_distance < 5000 THEN 'Group 1. Less than 5,000'
		WHEN avg_distance >=5000 AND avg_distance<=7000 THEN 'Group 2. 5,000 to 7,000'
		WHEN avg_distance >=7000 AND avg_distance<=9000 THEN 'Group 3. 7,000 to 9,000'
		ELSE 'Group 4. Greater than 9,000'
END
ORDER BY 'Distance Group';

-- Query 3: Retrieve the top 10 dangerous driver based on exceeding the speed limit sorted on the percentage of dangerous trip, display driving experince 
SELECT TOP(10)
    cd.driver_name, 
    CAST(AVG(sd.Speed) AS DECIMAL(10, 2)) AS avg_speed, 
    cd.No_of_Years_driving_exp,
    CAST(SUM(CASE WHEN sl.label = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(sl.bookingID) AS DECIMAL(10, 2)) AS 'Percentage_Of_Dangerous_Trip(%)'
FROM Cab_Driver cd
	JOIN Safety_Labels sl ON cd.driver_id = sl.driver_id
	JOIN Sensor_Data sd ON sl.bookingID = sd.bookingID
WHERE sd.Speed IS NOT NULL
	GROUP BY cd.driver_id, cd.driver_name, cd.No_of_Years_driving_exp
	HAVING AVG(sd.Speed) > 10
ORDER BY 'Percentage_Of_Dangerous_Trip(%)' DESC;