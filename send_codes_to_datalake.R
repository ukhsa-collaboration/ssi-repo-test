library(DBI)
library(odbc)

lake19_path <- readLines("C:/Users/simon.thelwall/r_stuff/SSI_sql_queries/dbase_strings/datalake19_string.txt")
lake19_path

cds <- read.csv("C:/Users/simon.thelwall/r_stuff/SSI_sql_queries/pfizer_all_cats_opcodes.csv")
head(cds)

table(cds$HESCategory)

dl_con <- odbc::dbConnect(odbc(),
                          Driver = "ODBC Driver 17 for SQL Server",
                          Server = stringr::str_replace(lake19_path, "\\\\", "\\"),
                          Database = "HES_PID_Analysis",
                          Trusted_Connection = "yes",
                          timeout = 120)

dbWriteTable(dl_con,
             name = "st_pfizer_all_cats_opcodes",
             value = cds,
             overwrite = TRUE)

dbDisconnect(dl_con)