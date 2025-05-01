use HES_PID_Analysis
go


-- Produce the SSI cat counts extract from HES

select pid.FYEAR
	  ,pid.EPIKEY
	  --,r.SUSRECID
	  --,pid.patientnhsnumber
	  ,pid.ENCRYPTED_HESID
	  ,p.FCE
	  ,p.STARTAGE
	  ,p.ADMIDATE_DV
	  ,p.Admimeth
	  ,case 
			when p.Admimeth in ('11','12','13') then 'Elective'
			when p.Admimeth = '28' then 'Other'
			when (p.Admimeth > '20'  and p.Admimeth <= '25')
					or (p.Admimeth in ('2A','2B','2C','2D')) then 'Emergency'
       else ''   
	   end as OpType
	  ,p.disdate_dv
	  ,p.dismeth
	  ,p.disdest
	  ,p.spelbgin
	  ,p.epistart_dv
	  ,p.epiend_dv
	  ,p.speldur
	  ,p.spelend
	  ,p.epidur
	  ,p.epiorder
	  ,p.epistat
	  ,p.mainspef
	  ,p.tretspef
	  ,p.classpat
	  ,p.provspno
	  ,p.provspnops
	  ,p.sitetret
	  ,pid.DOB_DV
	  ,p.SEX
	  ,pid.NEWNHSNO	  
	  ,p.ETHNOS
	  ,p.PROCODET
	  ,p.PROCODE
	  ,p.PROCODE3
	  ,p.PROTYPE 	  
	  ,o.OpertnIdx
	  ,o.OPERTN
	  ,o.OPDATE
	  ,o.OPDATE_DV	  
	  ,pf.HESCategory
--into SSI_cat_counts_16dec_2020
--into SSI_cat_counts_21dec_2020
--into dbo.SSI_cat_counts_06may_2021
--into dbo.SSI_cat_counts_06dec_2022
into dbo.ssi_cat_counts_2013_data_apr_2025
from HES_PID_APC.dbo.vtHES_PID_APC pid inner join HES_APC.dbo.vtHES_APC p on
pid.FYEAR = p.FYEAR
and pid.EPIKEY = p.EPIKEY
inner join HES_APC.[dbo].[vtHES_APC_OPERTN] o on
pid.FYEAR = o.FYEAR
and pid.EPIKEY = o.EPIKEY
--inner join  SSI_all_cats_opcodes_02072020 pf on
--inner join [dbo].[Pfizer_all_cats_opcodes_edited_16122020] pf on		-- 
inner join [HES_PID_Analysis].[PHE\Simon.Thelwall].[st_pfizer_all_cats_opcodes] pf on	
o.OPERTN = pf.CodeNoDot
where  p.FYEAR = '1314'
and o.OPERTN != '-'
and p.PROTYPE not in ('IND','INDSITE','INDSITETC') -- Only count the NHS sites
and ADMIMETH in ('11','12','13')	-- Select elective only cases


-- There are issues with this, because there are several duplicates between Hip and Knee where it is unclear what category the surgery 
-- is actually.
-- We must sort this out as best we can
-- Identify the duplicate Codes:

select CodeNodot
into dbo.SSI_ambig_codes
--from Pfizer_all_cats_opcodes_edited_16122020		-- contains the OPCS codes and their various categories
from [HES_PID_Analysis].[PHE\Simon.Thelwall].[st_pfizer_all_cats_opcodes]
group by CodeNoDot
having count(*) > 1
order by CodeNoDot

-- There are 23 duplicate codes
select *
from SSI_ambig_codes

-- select categories 6 and 7  out of the first file into their own file

select *
--into dbo.SSI_cat_counts_hip_knee_06may_2021
-- from dbo.SSI_cat_counts_06dec_2022
into dbo.SSI_cat_counts_hip_knee_apr_2025
from dbo.ssi_cat_counts_2013_data_apr_2025
where HESCategory in ('6', '7')

-- 148,406 records
/*
select *
	  ,case s.HESCategory
		  when '6' then 'Hip'
		  when '7' then 'Knee'
	   end as CatDesc
	  --,c.CodeDesc	  
	  ,row_number() over (partition by s.FYEAR, s.EPIKEY order by s.HESCategory) rownum
from SSI_cat_counts_hip_knee_06may_2021 s --inner join Pfizer_all_cats_opcodes_edited_16122020  c on
--s.OPERTN = c.CodeNoDot
order by FYEAR, EPIKEY

-- 173,182 rows
-- 173,182 - 148,406 = 24,776
*/

select *
from SSI_ambig_codes

select *
	  ,row_number() over(partition by FYEAR, EPIKEY order by HESCategory) rownum
--into dbo.SSI_cat_counts_ambig_cases
from SSI_cat_counts_hip_knee_06may_2021
where OPERTN in (
	select CodeNoDot
	from SSI_ambig_codes
	)
order by FYEAR, EPIKEY

alter table SSI_cat_counts_hip_knee_06may_2021
	add rownum int

select *
from SSI_cat_counts_hip_knee_06may_2021
order by FYEAR, EPIKEY

select *
from SSI_cat_counts_ambig_cases
union
select *
from SSI_cat_counts_hip_knee_06may_2021

select *
from SSI_cat_counts_ambig_cases

select FYEAR, count(*)
from SSI_cat_counts_hip_knee_06may_2021
group by FYEAR


select *
	  ,row_number() over(partition by epikey order by opdate_dv) rn
from SSI_cat_counts_hip_knee_06may_2021
where epikey in (
select distinct epikey
from SSI_cat_counts_ambig_cases
)
order by epikey


-- three rows, same opdate. One distinct hip replacement code. 
-- One code on two rows (hip row and a knee row) that could be either hip or knee 
select *
from SSI_cat_counts_hip_knee_06may_2021
where EPIKEY = '501613400974'