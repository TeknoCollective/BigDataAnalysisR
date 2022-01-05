# set the working path
setwd("/home/hduser/Desktop/CountriesSentiment/")
#required library
library(rtweet)
library(mongolite)
# all authentication variable for twitter account 
appname <- "myRproject12"

key <- "xxxxxxxxxxxxxxxxxxxxx"

secret <- "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
access_token <- "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
access_secret<- "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

twitter_token <- create_token(
  app = appname,
  consumer_key = key,
  consumer_secret = secret,
  access_token = access_token,
  access_secret = access_secret)

# tweets range
star_date <- "2020-04-14"
end_date <- "2020-04-21"

#UK tweets 
uktweet <- search_tweets(q = "uk", n =100000, lang = "en",
                              include_rts = FALSE,since = start_date,until = end_start)

#USA twees
usatweet <- search_tweets(q = "usa", n =100000, lang = "en",
                            include_rts = FALSE,since = start_date,until = end_date)

#Canada twees
canadatweet <- search_tweets(q = "canada", n =100000, lang = "en",
                          include_rts = FALSE,since = sart_date,until = end_date)


# Create UK twees database in mongo
ukdb <- mongo(collection = "uktweets",
           db = "ukdata",
           url = "mongodb://localhost")
usadb <- mongo(collection = "usatweets",
              db = "usadata",
              url = "mongodb://localhost")
canadadb <- mongo(collection = "canadatweets",
               db = "canadadata",
               url = "mongodb://localhost")

#data inserted into mongodb

ukdb$insert(uktweet)
usadb$insert(usadb)
canadadb$insert(canadadb)

# call the second script
source("dtanalysis.R")


