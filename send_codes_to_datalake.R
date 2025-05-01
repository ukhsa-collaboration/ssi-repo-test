library(DBI)
library(odbc)

cds <- read.csv("C:/Users/simon.thelwall/r_stuff/SSI_sql_queries/pfizer_all_cats_opcodes.csv")
head(cds)

table(cds$HESCategory)

dl_con <- odbc::dbConnect(odbc(),
                          Driver = "ODBC Driver 17 for SQL Server",
                          Server = "SQLCLUSCOLLK19.phe.gov.uk\\LAKE19",
                          Database = "HES_PID_Analysis",
                          Trusted_Connection = "yes",
                          timeout = 120)

dbWriteTable(dl_con,
             name = "st_pfizer_all_cats_opcodes",
             value = cds,
             overwrite = TRUE)

dbDisconnect(dl_con)