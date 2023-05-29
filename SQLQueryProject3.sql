select Make, model, [Electric Range]
from Electric_Vehicle_Population_Dat$
where [Electric Range] is not null
order by Make, model asc

select*
from Electric_Vehicle_Population_Dat$
where [Electric Vehicle Type] like '%BEV%'
	and [Electric Range] <> 0 
order by Make, model asc

select*
into Electric_vehicle_range
from Electric_Vehicle_Population_Dat$
where [Electric Vehicle Type] like '%BEV%'
	and [Electric Range] <> 0 
order by Make, model asc


--select Make, model, [Electric Range]
--from Electric_Vehicle_Population_Dat$
--create table Cars(
--model varchar(100)
--[Electric Range] INT
--)


select *
from Electric_vehicle_range
order by Make, model asc


select State, [Model Year], Make, model, [Electric Range]
from Electric_vehicle_range
order by [Model Year] asc




select Make, model,	round(AVG([Electric Range]),2) as AverageRange
from Electric_vehicle_range
group by make, model
order by Make, model asc

CREATE TABLE MakeModelAverageRange (
  Make VARCHAR(50),
  Model VARCHAR(50),
  AverageRange DECIMAL(10, 2)
)

INSERT INTO MakeModelAverageRange (Make, Model, AverageRange)
SELECT Make, Model, ROUND(AVG([Electric Range]), 2) AS AverageRange
FROM Electric_vehicle_range
GROUP BY Make, Model
ORDER BY Make, Model ASC;



alter table [MakeModelAverageRange]
add VIN varchar(50)

update MakeModelAverageRange
set VIM = Electric_Vehicle_Population_Dat$.[VIN (1-10)]
from MakeModelAverageRange
inner join Electric_Vehicle_Population_Dat$ on MakeModelAverageRange = Electric_Vehicle_Population_Dat$.Make
and MakeModelAverageRange.Model = Electric_Vehicle_Population_Dat$.Model


UPDATE MakeModelAverageRange
SET VIN = Electric_vehicle_range.[VIN (1-10)]
FROM MakeModelAverageRange
INNER JOIN Electric_vehicle_range ON MakeModelAverageRange.Make = Electric_vehicle_range.Make
    AND MakeModelAverageRange.Model = Electric_vehicle_range.Model;


select *
from MakeModelAverageRange


drop table if exists #ELECTRICVEHICLENUMBER
CREATE TABLE #ELECTRICVEHICLENUMBER
(
make nvarchar(255),
model nvarchar(255),
LegislativeDistrict numeric,
NumberOfCars int
)


insert into #ELECTRICVEHICLENUMBER(make, model, LegislativeDistrict, NumberOfCars)
select ran.Make, ran.AverageRange, ran.model, evr.[Legislative District], COUNT(*) as NumberOfCars
from MakeModelAverageRange ran
join Electric_vehicle_range evr
	on ran.Model=evr.model
	and ran.Make=ran.Make
group by ran.Make, ran.Model, evr.[Legislative District]