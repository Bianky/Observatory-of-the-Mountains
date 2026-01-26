# Script for downloading data through a query

# packages
library(httr)
library(jsonlite)
library(rjstat)  # helpful for JSON-stat format (IDESCAT uses JSON-stat) (see below)

# Specify the table you want:
statistic   <- "pmh"     # municipal register of inhabitants
node        <- "1180"    # by sex and age year by year
table_id    <- "8078"    # from 2014
geo         <- "com"     # counties
fil         <- "SEX=F&COM=TOTAL&_LAST_=1"

# counties
# 39 = Aran
# 05 = Alta Ribagorca
# 25 = Pallars Jussa
# 26 = Pallars Sobira
# 04 = Alt Urgell 
# 15 = Cerdanya
# 14 = Bergueda
# 31 = Ripolles
# TOTAL = Catalunya


#"https://api.idescat.cat/taules/v2" <- large statistical tables
#"https://api.idescat.cat/indicadors/v1" <- short time series of specific indicators

base_url <- "https://api.idescat.cat/taules/v2"
req_url  <- sprintf("%s/%s/%s/%s/%s/data?lang=en&%s", base_url,
                    statistic, node, table_id, geo, fil)

# If you also want filters you can append, e.g. &filter=YEAR/2020;SEX/1

resp <- GET(req_url)
stop_for_status(resp)

content_json <- content(resp, as="text", encoding="UTF-8")
# Parse JSON-stat format
data_list <- fromJSON(content_json)

# Use rjstat to convert if needed
df <- jsonlite::fromJSON(data_list)

head(df)