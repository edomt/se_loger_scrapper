library(rvest)
library(data.table)
library(stringr)
library(sendmailR)

# PARAMETERS START HERE
MEUBLE <- TRUE
NON_MEUBLE <- FALSE
PRIX_MAX <- 1100
SURFACE_MIN <- 27
EMAIL <- "me@email.com"
ARRONDISSEMENTS <- c(3, 12, 20)
# PARAMETERS STOP HERE

mbl <- ifelse(MEUBLE & NON_MEUBLE, "", ifelse(MEUBLE, "&furnished=1", "&furnished=0"))

ardts <- str_pad(ARRONDISSEMENTS, width = 2, side = "left", pad = "0")
ardts <- paste0("%7Bci%3A7501", ardts)
ardts <- paste(ardts, collapse = "%7D%7C")
ardts <- paste0("%5B", ardts, "%7D%5D")

url <- paste0("https://www.seloger.com/list.htm?types=1&projects=1&enterprise=0", mbl, "&price=NaN%2F", PRIX_MAX, "&surface=", SURFACE_MIN, "%2FNaN&places=", ardts, "&qsVersion=1.0")

page <- read_html(url)
links <- page %>% html_nodes(".c-pa-link") %>% html_attr("href") %>% str_replace('\\?.*$', '')

if (!file.exists('flats_known.txt')) file.create('flats_known.txt')
known <- readLines('flats_known.txt', warn = FALSE)

links <- setdiff(links, known)
message("SELOGER.COM: ", length(links), " FOUND")

for (link in links) {
  message(link)
  subj <- paste("FLAT ALERT SELOGER.COM", Sys.time())
  sendmail(from = "sender@email.com", to = EMAIL, subject = subj, msg = link, control = list(smtpServer = "localhost"))
  known <- c(readLines('flats_known.txt', warn = FALSE), link)
  writeLines(known, 'flats_known.txt')
  Sys.sleep(1)
}
