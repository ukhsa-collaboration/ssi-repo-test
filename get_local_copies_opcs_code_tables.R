library(odbc) # for working with databases
library(DBI) # for working with databases

setwd("C:/Users/simon.thelwall/r_stuff/ssi_r_stuff/SSI_sql_queries")

con <- odbc::dbConnect(
  odbc()
  , Driver = "SQL Server"
  , Server = "SQLCLUSCOLLK19.phe.gov.uk\\LAKE19"
  , Database = "HES_PID_Analysis"
)

qry <- "select * from [HES_PID_Analysis].[dbo].[Pfizer_all_cats_opcodes_edited_16122020_PHDS_will_delete_on_2024-02-01]"

all_cat_opcodes <- dbGetQuery(con, qry)

write.csv(all_cat_opcodes, "pfizer_all_cats_opcodes.csv", row.names = FALSE)

rm(qry)
qry <- "select * from [HES_PID_Analysis].[dbo].[Pfizer_HES_cats_PHDS_will_delete_on_2024-02-01]"

HES_cat_opcodes <- dbGetQuery(con, qry)
head(HES_cat_opcodes)

write.csv(HES_cat_opcodes, "pfizer_HES_cats.csv", row.names = FALSE)