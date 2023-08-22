# SQL Project 6 - Exploratory Data Analysis - Airline Passenger Satisfaction Survey Data Analysis

## Complete code attached - Airline Passenger Satisfaction.sql

## Data Insights Using SQL.

### 1) Satisfaction Vs Dissatisfaction rate.
```
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
```
![image](https://github.com/JoshuaSequeira2000/SQL-Project-6-Airline-Passenger-Satisfaction-Survey-Data-Analysis/assets/92262753/4d756376-67aa-4701-8a6d-d296fe574982)\
Result:\
The satisfaction count dropped below 50% at a total of 43.45%.

### 2a) Number of Male Vs Female passengers.
```
select Gender, FORMAT(COUNT(Gender), '##,###') as Number_Of_Passengers 
from Airline_Passenger_Satisfaction
group by Gender
GO
```
![image](https://github.com/JoshuaSequeira2000/SQL-Project-6-Airline-Passenger-Satisfaction-Survey-Data-Analysis/assets/92262753/6e6f219a-6320-42ed-b99e-bd67f0dc49e1)\
Result:\
Roughly 2,000 more female passengers than male passengers.

### 2b) Number of Male Vs Female passengers who are satisfied/dissatisfied.
```
select Gender, case when Satisfaction is null then 'TOTAL' else Satisfaction end as Satisfaction, -- case when used to remove NULL value received from grouping sets.
format(COUNT(Satisfaction), '##,###') as Result
from Airline_Passenger_Satisfaction
group by grouping sets ((Gender, Satisfaction),(Gender)) -- Grouping sets used to get the totals based on gender
GO 
```
![image](https://github.com/JoshuaSequeira2000/SQL-Project-6-Airline-Passenger-Satisfaction-Survey-Data-Analysis/assets/92262753/461717fa-b1e2-4d53-ae45-2149436fa772)\
Result:\
The dissatisfaction rate was higher for both male and female passengers.

### 3) Number of Male vs Female passengers who are satisfied/dissatisfied based on age brackets.
```
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
-- where Satisfaction = 'Satisfied' -- Filter to get result based on Satisfaction value passed.
group by Gender, Age_Bracket, Satisfaction
order by COUNT(Result)
GO 
```
![image](https://github.com/JoshuaSequeira2000/SQL-Project-6-Airline-Passenger-Satisfaction-Survey-Data-Analysis/assets/92262753/46aeeb76-9a0f-4e30-9da1-30ed15e365ee)\
Result:\
The highest dissatisfaction rate was found in Female adults between the ages of 30 and 59.\
The lowest dissatisfaction rate was found in Male Seniors, aged 60 & above.\
The highest satisfaction rate was found in Male adults between the ages of 30 and 59.\
The lowest satisfaction rate was found in Children (both male and female) between the age of 7 to 18.

### 4) Satisfaction rate based on Flight Class. 
```
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
```
![image](https://github.com/JoshuaSequeira2000/SQL-Project-6-Airline-Passenger-Satisfaction-Survey-Data-Analysis/assets/92262753/0845c769-9ee9-43a5-82c2-b5a527c94518)\
Result:\
As found within the data, the majority of Business class passengers felt satisfied with their flight. The total satisfaction rate was approx 70%.\
The highest dissatisfaction rate was found in Ecomony class passengers with a total of 81.23%, followed by Ecomony Plus passengers at 75.36%.

### 5) Satisfaction rate based on Customer Type.
```
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
```
![image](https://github.com/JoshuaSequeira2000/SQL-Project-6-Airline-Passenger-Satisfaction-Survey-Data-Analysis/assets/92262753/a169c3b4-c73e-4360-bfad-5d23ba7fd1f6)\
Result:\
The ratio between satisfied and dissatisfied passengers was higher for first-time travelers as compared to returning passengers.\
Approx 76% of first-time passengers were dissatisfied, while for returning passengers, the ratio was closer, at approx 47:52.

### 6) Avg for all Measures (Rated between 1 as lowest to 5 as highest)
### 6a) Avg Departure_and_Arrival_Time_Convenience.
```
select format(AVG(Cast((Departure_and_Arrival_Time_Convenience) as decimal(3,2))), '##.##') as Avg_Departure_and_Arrival_Time_Convenience
from Airline_Passenger_Satisfaction
GO
```
![image](https://github.com/JoshuaSequeira2000/SQL-Project-6-Airline-Passenger-Satisfaction-Survey-Data-Analysis/assets/92262753/e4986360-cad9-44e8-8138-dc46a1ef2d15)

### 6b) Avg Ease_of_Online_Booking.
```
select format(AVG(Cast((Ease_of_Online_Booking) as decimal(3,2))), '##.##') as Avg_Ease_of_Online_Booking
from Airline_Passenger_Satisfaction
GO
```
![image](https://github.com/JoshuaSequeira2000/SQL-Project-6-Airline-Passenger-Satisfaction-Survey-Data-Analysis/assets/92262753/72afc1bd-f3b3-455f-9a35-567de20d93c6)

### 6c) Avg Check_in_Service.
```
select format(AVG(Cast((Check_in_Service) as decimal(3,2))), '##.##') as Avg_Check_in_Service
from Airline_Passenger_Satisfaction
GO
```
![image](https://github.com/JoshuaSequeira2000/SQL-Project-6-Airline-Passenger-Satisfaction-Survey-Data-Analysis/assets/92262753/f9ba820e-f733-4707-90f4-883f1a7322ee)

### 6d) Avg Online_Boarding.
```
select format(AVG(Cast((Online_Boarding) as decimal(3,2))), '##.##') as Avg_Online_Boarding
from Airline_Passenger_Satisfaction
GO
```
![image](https://github.com/JoshuaSequeira2000/SQL-Project-6-Airline-Passenger-Satisfaction-Survey-Data-Analysis/assets/92262753/f92cc61e-b89a-45fa-b13d-173471e239ed)

### 6e) Avg Gate_Location.
```
select format(AVG(Cast((Gate_Location) as decimal(3,2))), '##.##') as Avg_Gate_Location
from Airline_Passenger_Satisfaction
GO
```
![image](https://github.com/JoshuaSequeira2000/SQL-Project-6-Airline-Passenger-Satisfaction-Survey-Data-Analysis/assets/92262753/769ef76b-2176-467a-8e93-622085b9b900)

### 6f) Avg On_board_Service.
```
select format(AVG(Cast((On_board_Service) as decimal(3,2))), '##.##') as Avg_On_board_Service
from Airline_Passenger_Satisfaction
GO
```
![image](https://github.com/JoshuaSequeira2000/SQL-Project-6-Airline-Passenger-Satisfaction-Survey-Data-Analysis/assets/92262753/dc4f14b4-6f00-435c-90b5-2f4530ec8c09)

### 6g) Avg Seat_Comfort.
```
select format(AVG(Cast((Seat_Comfort) as decimal(3,2))), '##.##') as Avg_Seat_Comfort
from Airline_Passenger_Satisfaction
GO
```
![image](https://github.com/JoshuaSequeira2000/SQL-Project-6-Airline-Passenger-Satisfaction-Survey-Data-Analysis/assets/92262753/9359fcf0-c379-426f-9f55-fcccdb0a1d93)

### 6h) Avg Leg_Room_Service.
```
select format(AVG(Cast((Leg_Room_Service) as decimal(3,2))), '##.##') as Avg_Leg_Room_Service
from Airline_Passenger_Satisfaction
GO
```
![image](https://github.com/JoshuaSequeira2000/SQL-Project-6-Airline-Passenger-Satisfaction-Survey-Data-Analysis/assets/92262753/acf7d142-bec4-4756-8d0e-0e5faabce128)

### 6i) Avg Cleanliness.
```
select format(AVG(Cast((Cleanliness) as decimal(3,2))), '##.##') as Avg_Cleanliness
from Airline_Passenger_Satisfaction
GO
```
![image](https://github.com/JoshuaSequeira2000/SQL-Project-6-Airline-Passenger-Satisfaction-Survey-Data-Analysis/assets/92262753/190dc3ab-1229-4da2-b0e4-dfb4ffa132f3)

### 6j) Avg Food_and_Drink.
```
select format(AVG(Cast((Food_and_Drink) as decimal(3,2))), '##.##') as Avg_Food_and_Drink
from Airline_Passenger_Satisfaction
GO
```
![image](https://github.com/JoshuaSequeira2000/SQL-Project-6-Airline-Passenger-Satisfaction-Survey-Data-Analysis/assets/92262753/b17b6af6-c4da-4805-9584-4eefdd75a334)

### 6k) Avg In_flight_Service.
```
select format(AVG(Cast((In_flight_Service) as decimal(3,2))), '##.##') as Avg_In_flight_Service
from Airline_Passenger_Satisfaction
GO
```
![image](https://github.com/JoshuaSequeira2000/SQL-Project-6-Airline-Passenger-Satisfaction-Survey-Data-Analysis/assets/92262753/a1b6a71a-4d99-4ff6-9a9f-6b7e2fee7ed3)

### 6l) Avg In_flight_Wifi_Service.
```
select format(AVG(Cast((In_flight_Wifi_Service) as decimal(3,2))), '##.##') as Avg_In_flight_Wifi_Service
from Airline_Passenger_Satisfaction
GO
```
![image](https://github.com/JoshuaSequeira2000/SQL-Project-6-Airline-Passenger-Satisfaction-Survey-Data-Analysis/assets/92262753/436d1bdf-486c-4e5a-9066-048089590b78)

### 6m) Avg In_flight_Entertainment.
```
select format(AVG(Cast((In_flight_Entertainment) as decimal(3,2))), '##.##') as Avg_In_flight_Entertainment
from Airline_Passenger_Satisfaction
GO
```
![image](https://github.com/JoshuaSequeira2000/SQL-Project-6-Airline-Passenger-Satisfaction-Survey-Data-Analysis/assets/92262753/71a3727c-d8da-4a98-8cab-5a907d76d8d8)

### 6n) Avg Baggage_Handling.
```
select format(AVG(Cast((Baggage_Handling) as decimal(3,2))), '##.##') as Avg_Baggage_Handling
from Airline_Passenger_Satisfaction
GO
```
![image](https://github.com/JoshuaSequeira2000/SQL-Project-6-Airline-Passenger-Satisfaction-Survey-Data-Analysis/assets/92262753/84a482a3-f130-4c5c-894e-b0aaf66ff160)\
Result:\
In-flight Wifi service and online booking were ranked the worse by passengers with an average score of 2.73 and 2.76 respectively.\
In-flight service and baggage handling were ranked the highest by passengers with an average score of 3.64 and 3.63 respectively.

### 7) Avg Departure and Arrival Delay.
```
select Concat_Ws(' - ', AVG(Departure_Delay), 'Minutes') as Avg_Departure_Delay
from Airline_Passenger_Satisfaction
GO

select Concat_Ws(' - ', AVG(Arrival_Delay), 'Minutes') as Avg_Arrival_Delay
from Airline_Passenger_Satisfaction
GO
```
![image](https://github.com/JoshuaSequeira2000/SQL-Project-6-Airline-Passenger-Satisfaction-Survey-Data-Analysis/assets/92262753/40c065ee-00dd-4ef7-a2bc-8a0834f7e5c5)

