use HES_PID_Analysis
go

/*
These are the main files currently

SSI_cat_counts_hip_knee_06may_2021		-- the original hip and knee file unaltered (cats 6 and 7 only)
148,406

dbo.[SSI_cat_counts_hip_knee_06may_2021_ambig_cases_episodes]  -- all ambiguous cases by episode plus any unambig cases in that episode
30,257

[dbo].[SSI_cat_counts_hip_knee_06may_2021_ambig_cases_deduped_v2] -- the file of duplicates, with unnecessary extra cases deleted
11,038
*/

select *
from SSI_cat_counts_hip_knee_06may_2021


select *
from dbo.[SSI_cat_counts_hip_knee_06may_2021_ambig_cases_episodes]
------------------------------------------------------------------------------------------


select FYEAR
	  ,EPIKEY
	  ,ENCRYPTED_HESID
	  ,ADMIDATE_DV
	  ,OpertnIdx
	  ,OPERTN
	  ,OPDATE_DV
	  ,HESCategory
from SSI_cat_counts_hip_knee_06may_2021
where EPIKEY in (
	select EPIKEY
	from SSI_cat_counts_hip_knee_06may_2021_ambig_cases_episodes
	)

select FYEAR
	  ,EPIKEY
	  ,ENCRYPTED_HESID
	  ,ADMIDATE_DV
	  ,OpertnIdx
	  ,OPERTN
	  ,OPDATE_DV
	  ,HESCategory
from SSI_cat_counts_hip_knee_06may_2021_ambig_cases_episodes
where EPIKEY in (
	select EPIKEY
	from SSI_cat_counts_hip_knee_06may_2021_ambig_cases_deduped_v2
	)
order by EPIKEY, OpertnIdx



select *
from SSI_cat_counts_hip_knee_06may_2021_ambig_cases_deduped_v2
order by EPIKEY, rownum

select *
from SSI_cat_counts_hip_knee_06may_2021_ambig_cases_deduped
where HESCategory != NewCat

-----------------------------------------------------------------------------------------------------

select *
from SSI_cat_counts_hip_knee_06may_2021_ambig_cases_episodes a 
inner join SSI_cat_counts_hip_knee_06may_2021_ambig_cases_deduped_v2 d on
a.EPIKEY = d.EPIKEY and a.HESCategory = d.NewCat
where a.EPIKEY = '501613401472'

select *
from SSI_cat_counts_hip_knee_06may_2021_ambig_cases_episodes


select *
from SSI_cat_counts_hip_knee_06may_2021_ambig_cases_deduped
order by EPIKEY

select *
from SSI_cat_counts_hip_knee_06may_2021_ambig_cases_deduped
where HESCategory != NewCat
order by EPIKEY
-- 5,531


select *
from SSI_cat_counts_hip_knee_06may_2021_ambig_cases_deduped
where HESCategory = NewCat
order by EPIKEY
-- 11,038


select *
from SSI_cat_counts_hip_knee_06may_2021_ambig_cases_deduped_v2
order by EPIKEY