-- Using Database
use [Airline Flight Satisfaction]
GO

-- Table created by importing CSV files. 
GO

-- Select statement
select * from Airline_Passenger_Satisfaction
GO

-- Exploratory Data Analysis
GO

-- 1) Satisfaction Vs Dissatisfaction rate.
select C.Satisfaction, C.Satisfaction_Count, concat(FORMAT(C.Percentage_Total, '##.##'), '%') as Percentage_Total -- Format function used to get percentage total in percentage format along with concat function to append % sign at the end of the percentage value.
from
	(select B.Satisfaction, B.Satisfaction_Count, 
	cast(B.Satisfaction_Count as decimal(10,2)) / 
	cast(B.Total as decimal (10,2)) * 100 as Percentage_Total  -- cast used to convert integer satisfaction count into decimal in order to receive result in decimal format.
	from
		(select A.*, 
		 SUM(A.Satisfaction_Count) over() as Total -- windows aggregate function to sum the total satisfaction count.
		from
			(
				select Satisfaction, COUNT(Satisfaction) as Satisfaction_Count
				from Airline_Passenger_Satisfaction
				group by Satisfaction 
			) as A -- subquery to store the satisfaction count.
				) as B -- subquery to store the percentage total.
					) as C -- subquery to store the final formatted percentage value.
GO
-- Result:
-- The satisfaction count dropped below 50% at a total of 43.45%.
GO

-- 2a) Number of Male Vs Female passengers
select Gender, FORMAT(COUNT(Gender), '##,###') as Number_Of_Passengers 
from Airline_Passenger_Satisfaction
group by Gender
GO
-- Result
-- Roughly 2,000 more female passengers than male passengers.
GO

-- 2b) Number of Male Vs Female passengers who are satisfied / dissatisfied.
select Gender, case when Satisfaction is null then 'TOTAL' else Satisfaction end as Satisfaction, -- case when used to remove NULL value received from grouping sets.
format(COUNT(Satisfaction), '##,###') as Result
from Airline_Passenger_Satisfaction
group by grouping sets ((Gender, Satisfaction),(Gender)) -- Grouping sets used to get the totals based on gender
GO 
-- Result
-- The dissatisfaction rate was higher for both male and female passengers.

GO
-- 3) Number of Male vs Female passengers who are satisfied / dissatisfied based on age brackets.
with satisfied_dissatisfied_AgeBrackets as
(
	select Gender, Age, case when Age between 7 and 18 then '1) Children - Age 7 to 18'
					when Age between 19 and 29 then '2) Young Adults - Age 19 to 29'
					when Age between 30 and 59 then '3) Adults - Age 30 to 59'
					when Age > 59 then '4) Seniors - Age 60 & Above' end Age_Bracket,
		   Satisfaction,
		   Satisfaction as Result
    from Airline_Passenger_Satisfaction
)
select Gender, Age_Bracket, Satisfaction, format(COUNT(Result), '##,###') as Result
from satisfied_dissatisfied_AgeBrackets
where Satisfaction = 'Satisfied' -- Filter to get result based on Satisfaction value passed.
group by Gender, Age_Bracket, Satisfaction
order by COUNT(Result)
GO 
-- Result:
-- Highest dissatisfaction rate was found in Female adults between the age's of 30 and 59.
-- Lowest dissatisfaction rate was found in Male Seniors, age 60 & above.
-- Highest satisfaction rate was found in Male adults between the age's of 30 and 59.
-- Lowest satisfaction rate was found in Children (both male and female) between the age'f of 7 to 18.
GO

-- 4) Satisfaction rate based on Flight Class. 
select C.Class, C.Satisfaction, C.Satisfaction_Count, concat(FORMAT(C.Percentage_Total, '##.##'), '%') as Percentage_Total -- Format function used to get percentage total in percentage format along with concat function to append % sign at the end of the percentage value.
from
	(select B.Class, B.Satisfaction, B.Satisfaction_Count, 
	cast(B.Satisfaction_Count as decimal(10,2)) / 
	cast(B.Total as decimal (10,2)) * 100 as Percentage_Total  -- cast used to convert integer satisfaction count into decimal in order to receive result in decimal format.
	from
		(select A.*, 
		 SUM(A.Satisfaction_Count) over(partition by A.Class) as Total -- windows aggregate function to sum the total satisfaction count basis the flight class type.
		from
			(
				select Class, Satisfaction, COUNT(Satisfaction) as Satisfaction_Count
				from Airline_Passenger_Satisfaction
				group by Class, Satisfaction 
			) as A -- subquery to store the satisfaction count.
				) as B -- subquery to store the percentage total.
					) as C -- subquery to store the final formatted percentage value.
GO
-- Result:
-- As found within the data, majority Business class passengers felt satisfied with their flight. The total satisfaction rate was approx 70%.
-- Highest dissatisfaction rate was found in Ecomony class passengers with a total of 81.23%, followed by Ecomony Plus passengers at 75.36%.
GO

-- 5) Satisfaction rate based on Customer Type.
select C.Customer_Type, C.Satisfaction, C.Satisfaction_Count, concat(FORMAT(C.Percentage_Total, '##.##'), '%') as Percentage_Total
from
	(select B.Customer_Type, B.Satisfaction, B.Satisfaction_Count,
	cast(B.Satisfaction_Count as decimal(10,2)) / cast(B.Total as decimal (10,2)) * 100 as Percentage_Total  from
		(select A.*, SUM(A.Satisfaction_Count) over(partition by A.Customer_Type) as Total
		from
			(
				select Customer_Type, Satisfaction, COUNT(Satisfaction) as Satisfaction_Count
				from Airline_Passenger_Satisfaction
				group by Customer_Type, Satisfaction 
			) as A -- subquery to store the satisfaction count.
				) as B -- subquery to store the percentage total.
					) as C -- subquery to store the final formatted percentage value.
GO
-- Result:
-- The ratio between satisfied and dissatisfied passengers was higher for first time travellers as compared to returning passengers.
-- Approx 76% first time passengers were dissatisfied, while for returning passengers, the ratio closer, at approx 47:52.
GO

-- 6) Avg for all Measures (Rated between 1 as lowest to 5 as highest)
-- 6a) Avg Departure_and_Arrival_Time_Convenience.
select format(AVG(Cast((Departure_and_Arrival_Time_Convenience) as decimal(3,2))), '##.##') as Avg_Departure_and_Arrival_Time_Convenience
from Airline_Passenger_Satisfaction
GO

-- 6b) Avg Ease_of_Online_Booking.
select format(AVG(Cast((Ease_of_Online_Booking) as decimal(3,2))), '##.##') as Avg_Ease_of_Online_Booking
from Airline_Passenger_Satisfaction
GO

-- 6c) Avg Check_in_Service.
select format(AVG(Cast((Check_in_Service) as decimal(3,2))), '##.##') as Avg_Check_in_Service
from Airline_Passenger_Satisfaction
GO

-- 6d) Avg Online_Boarding.
select format(AVG(Cast((Online_Boarding) as decimal(3,2))), '##.##') as Avg_Online_Boarding
from Airline_Passenger_Satisfaction
GO

-- 6e) Avg Gate_Location.
select format(AVG(Cast((Gate_Location) as decimal(3,2))), '##.##') as Avg_Gate_Location
from Airline_Passenger_Satisfaction
GO

-- 6f) Avg On_board_Service.
select format(AVG(Cast((On_board_Service) as decimal(3,2))), '##.##') as Avg_On_board_Service
from Airline_Passenger_Satisfaction
GO

-- 6g) Avg Seat_Comfort.
select format(AVG(Cast((Seat_Comfort) as decimal(3,2))), '##.##') as Avg_Seat_Comfort
from Airline_Passenger_Satisfaction
GO

-- 6h) Avg Leg_Room_Service.
select format(AVG(Cast((Leg_Room_Service) as decimal(3,2))), '##.##') as Avg_Leg_Room_Service
from Airline_Passenger_Satisfaction
GO

-- 6i) Avg Cleanliness.
select format(AVG(Cast((Cleanliness) as decimal(3,2))), '##.##') as Avg_Cleanliness
from Airline_Passenger_Satisfaction
GO

-- 6j) Avg Food_and_Drink.
select format(AVG(Cast((Food_and_Drink) as decimal(3,2))), '##.##') as Avg_Food_and_Drink
from Airline_Passenger_Satisfaction
GO

-- 6k) Avg In_flight_Service.
select format(AVG(Cast((In_flight_Service) as decimal(3,2))), '##.##') as Avg_In_flight_Service
from Airline_Passenger_Satisfaction
GO

-- 6l) Avg In_flight_Wifi_Service.
select format(AVG(Cast((In_flight_Wifi_Service) as decimal(3,2))), '##.##') as Avg_In_flight_Wifi_Service
from Airline_Passenger_Satisfaction
GO

-- 6m) Avg In_flight_Entertainment.
select format(AVG(Cast((In_flight_Entertainment) as decimal(3,2))), '##.##') as Avg_In_flight_Entertainment
from Airline_Passenger_Satisfaction
GO

-- 6n) Avg Baggage_Handling.
select format(AVG(Cast((Baggage_Handling) as decimal(3,2))), '##.##') as Avg_Baggage_Handling
from Airline_Passenger_Satisfaction
GO

-- Result:
-- In flight Wifi service and online booking were ranked the worse by passengers with an average score of 2.73 and 2.76 respectively.
-- In flight service and baggage handling were ranked the highest by passengers with an average score of 3.64 and 3.63 respectively.
GO

-- 7) Avg Departure and Arrival Delay.
select Concat_Ws(' - ', AVG(Departure_Delay), 'Minutes') as Avg_Departure_Delay
from Airline_Passenger_Satisfaction
GO

select Concat_Ws(' - ', AVG(Arrival_Delay), 'Minutes') as Avg_Arrival_Delay
from Airline_Passenger_Satisfaction
GO