use ssi
go



-- Find the Hospitals that have used the NHFD macro for their SSI cases

with x as (
select max(sd.serialnumber) serialmax 
	  ,min(sd.serialnumber) serialmin
	  ,count(sd.serialnumber) serialcount
      ,h.LegacyId
	  ,h.[Name]			    HospitalName
	  ,datepart(quarter,getdate()) [Quarter]
	  ,datepart(YEAR,getdate()) [Year]	  
from surveyparticipation sp inner join surveydata sd on sp.id = sd.surveyparticipationid
inner join hospital h on h.id = sp.hospitalid
inner join participationperiod pp on pp.id = sp.ParticipationPeriodId 
--where pp.periodstartdate >= '20160401'
where sd.AuditDelete is null
and h.[Name] not like 'test%'			-- comment this line out to include the test hospitals
and (sd.SerialNumber >= 150000000 and sd.SerialNumber < 160000000)	-- this range used exclusively by the NHFD macro
--and sd.SerialNumber <= 200000000
group by h.LegacyId, h.Name
)
select x.HospitalName
	  ,x.LegacyId
	  ,x.serialcount
	  ,x.serialmax
	  ,x.serialmin
	  ,x.[Quarter]
	  ,x.[Year]
	  from x
--where x.HospitalName like 'Spire%'
--order by serialcount desc		-- order the output by the serial number count, descending
--order by serialmax desc		-- order the output by the max serial number, descending
--order by x.serialmin asc
order by x.HospitalName	

-- NEW
-- Include quarter and year for relevant records, and group by them also NH 1/10/2020

with x as (
select min(sd.serialnumber) serialmin
	  ,max(sd.serialnumber) serialmax 
	  ,count(sd.serialnumber) serialcount
      ,h.LegacyId
	  ,h.[Name]			    HospitalName
	  --,pp.[Name]
	  --,pp.Id
	  --,pp.PeriodStartDate
	  --,pp.PeriodEndDate
	  ,datepart(quarter,sd.AuditCreate) [QuarterCreation]
	  ,datepart(YEAR,sd.AuditCreate) [YearCreation]	  
from surveyparticipation sp inner join surveydata sd on sp.id = sd.surveyparticipationid
inner join hospital h on h.id = sp.hospitalid
inner join participationperiod pp on pp.id = sp.ParticipationPeriodId 
--where pp.periodstartdate >= '20160401'
where sd.AuditDelete is null
and h.[Name] not like 'test%'			-- comment this line out to include the test hospitals
--and (sd.SerialNumber >= 150000000 and sd.SerialNumber < 160000000)	-- this range used exclusively by the NHFD macro
and (sd.SerialNumber >= 160000000 and sd.SerialNumber < 169000000)
--and sd.SerialNumber <= 200000000
--group by h.LegacyId, h.Name, datepart(quarter,sd.AuditCreate), datepart(YEAR,sd.AuditCreate)
group by h.LegacyId, h.[Name], pp.[Name], datepart(quarter,sd.AuditCreate), datepart(YEAR,sd.AuditCreate)--pp.PeriodStartDate, pp.PeriodEndDate
)
select x.HospitalName
	  ,x.LegacyId
	  ,x.serialcount
	  ,x.serialmin
	  ,x.serialmax
	  --,x.[Name] [periods]
	  --,x.PeriodStartDate
	  --,x.PeriodEndDate
	  ,x.[QuarterCreation]
	  ,x.[YearCreation]
--into ##ssi_cases_ser_170_180
	  from x 
order by x.HospitalName, x.YearCreation, x.QuarterCreation
--x.[Name] --x.PeriodStartDate, x.PeriodEndDate

select distinct Yearcreation
from ##ssi_cases_ser_170_180

