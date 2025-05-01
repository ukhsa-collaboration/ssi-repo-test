use HES_PID_Analysis
go



select *
	  ,row_number() over(partition by epikey order by opdate_dv) rn
from SSI_cat_counts_hip_knee_06may_2021
where epikey in (
select distinct epikey
from SSI_cat_counts_ambig_cases
)
order by epikey




-- this table doesn't exist anyway? Suspect this is to drop the table generated below in case it does exist
drop table dbo.[SSI_cat_counts_hip_knee_06may_2021_ambig_cases_episodes]


SELECT [FYEAR]
      ,[EPIKEY]
      ,[ENCRYPTED_HESID]
      ,[FCE]
      ,[STARTAGE]
      ,[ADMIDATE_DV]
      ,[Admimeth]
      ,[OpType]
      ,[disdate_dv]
      ,[dismeth]
      ,[disdest]
      ,[spelbgin]
      ,[epistart_dv]
      ,[epiend_dv]
      ,[speldur]
      ,[spelend]
      ,[epidur]
      ,[epiorder]
      ,[epistat]
      ,[mainspef]
      ,[tretspef]
      ,[classpat]
      ,[provspno]
      ,[provspnops]
      ,[sitetret]
      ,[DOB_DV]
      ,[SEX]
      ,[NEWNHSNO]
      ,[ETHNOS]
      ,[PROCODET]
      ,[PROCODE]
      ,[PROCODE3]
      ,[PROTYPE]
      ,[OpertnIdx]
      ,[OPERTN]
      ,[OPDATE]
      ,[OPDATE_DV]
      ,[HESCategory]  
	  ,row_number() over(partition by epikey order by opdate_dv) rownum
into dbo.[SSI_cat_counts_hip_knee_06may_2021_ambig_cases_episodes]
FROM [dbo].[SSI_cat_counts_hip_knee_06may_2021]
where epikey in (
select distinct epikey
from SSI_cat_counts_ambig_cases
)
order by EPIKEY
GO

/*
update [SSI_cat_counts_hip_knee_06may_2021_ambig_cases_episodes]
	set rownum = row_number() over(partition by epikey order by opdate_dv)
*/

-- add the ambig flag
alter table [SSI_cat_counts_hip_knee_06may_2021_ambig_cases_episodes]
	add ambig char(1)
go


-- set the flag for the codes concerned
update [SSI_cat_counts_hip_knee_06may_2021_ambig_cases_episodes]
	set ambig = 'Y'
	where OPERTN in
	( select c.CodeNodot
	from SSI_ambig_codes c
	)

select *
from SSI_cat_counts_hip_knee_06may_2021_ambig_cases_episodes

select * 
	  --,'Y' as ambig
from [SSI_cat_counts_hip_knee_06may_2021_ambig_cases_episodes] e 
where e.OPERTN in
	( select c.CodeNodot
	from SSI_ambig_codes c
	)

select *
--into [dbo].[SSI_cat_counts_hip_knee_06may_2021_ambig_cases_dups]
from [SSI_cat_counts_hip_knee_06may_2021_ambig_cases_episodes] e
where e.EPIKEY in
	(select s.epikey
	from [SSI_cat_counts_hip_knee_06may_2021_ambig_cases_episodes] s
	where s.ambig is null
	)
order by epikey, ambig



select s.*
	  ,a.NewCat
	  --,a.to_delete
	  ,c.[Description]	
into SSI_cat_counts_hip_knee_06may_2021_ambig_cases_deduped
from [SSI_cat_counts_hip_knee_06may_2021_ambig_cases_dups] s inner join LookupsShared.dbo.vClinical_OPCS48 c
on s.OPERTN = c.Code
cross apply ( select a.HESCategory
					,a.ambig
				    ,a.HESCategory as NewCat
				    --,'Y' as [to_delete]
			  from [SSI_cat_counts_hip_knee_06may_2021_ambig_cases_dups] a
			  where a.FYEAR = s.FYEAR and
					a.EPIKEY = s.EPIKEY and
					a.ambig is null
			) a
order by s.EPIKEY, s.ambig

--drop table tempdb..#ssitemp


select count(*) cnt
from [SSI_cat_counts_hip_knee_06may_2021_ambig_cases_dups]


select FYEAR
	  ,EPIKEY
	  ,OpertnIdx
	  ,OPERTN	  
	  ,OPDATE_DV
	  ,HESCategory
	  ,NewCat
	  ,rownum
	  ,ambig
	  ,case when HESCategory = NewCat then ''
		    when HESCategory != NewCat then 'Y'
	  else NULL
	  end as delflag
	  ,[description]
into SSI_cat_counts_hip_knee_06may_2021_ambig_cases_deduped_v2
from SSI_cat_counts_hip_knee_06may_2021_ambig_cases_deduped
order by EPIKEY, ambig
go


select *
from SSI_cat_counts_hip_knee_06may_2021_ambig_cases_deduped_v2
order by EPIKEY, ambig

delete SSI_cat_counts_hip_knee_06may_2021_ambig_cases_deduped_v2
where delflag = 'Y'

-- shift the table concerned into the 'DBO' schema
ALTER SCHEMA dbo
TRANSFER [PHE\Nick.Hinton].[SSI_cat_counts_hip_knee_06may_2021_ambig_cases_deduped]

select *
from dbo.[SSI_cat_counts_hip_knee_06may_2021_ambig_cases_deduped_v2]
order by EPIKEY, ambig