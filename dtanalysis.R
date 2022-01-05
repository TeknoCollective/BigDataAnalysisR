# Required library
library(sparklyr)
library(mongolite)
library(tm)
library(ggplot2)
library(dplyr)

# call the spark 
Sys.setenv(SPARK_HOME ='/home/hduser/Desktop/spark-2.4.5')
sc <- spark_connect(master = "local")

# retrive the collection from the mongo
ukdb <- mongo(collection = "uktweets",
              db = "ukdata",
              url = "mongodb://localhost")

usadb <- mongo(collection = "usatweets",
               db = "usadata",
               url = "mongodb://localhost")

canadadb <- mongo(collection = "canadatweets",
                  db = "canadadata",
                  url = "mongodb://localhost")


#load data into spark memory
datacollect<-sdf_copy_to(sc,as.data.frame(ukdb$find(limit = 10000)%>%select(text)),overwrite = T)
datacollect2<-sdf_copy_to(sc,as.data.frame(usadb$find(limit = 10000)%>%select(text)),overwrite = T)
datacollect3<-sdf_copy_to(sc,as.data.frame(canadadb$find(limit = 10000)%>%select(text)),overwrite = T)

pdata<-datacollect
pdata2<-datacollect2
pdata3<-datacollect3

# data extracting and cleaning
New <- pdata%>%collect() 

New$text=gsub("http\\w+", "", New$text)  
New$text=gsub("&amp", "", New$text)
New$text = gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", New$text)
New$text = gsub("@\\w+", "", New$text)
New$text = gsub("[[:punct:]]", "", New$text)
New$text = gsub("[[:digit:]]", "", New$text)
New$text = gsub("[ \t]{2,}", "", New$text)
New$text = gsub("^\\s+|\\s+$", "", New$text)
New$text <- iconv(New$text, "UTF-8", "ASCII", sub="")
New$text<- removeWords(New$text, stopwords("en"))

New2 <- pdata2%>%collect() 

New2$text=gsub("http\\w+", "", New2$text)  
New2$text=gsub("&amp", "", New2$text)
New2$text = gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", New2$text)
New2$text = gsub("@\\w+", "", New2$text)
New2$text = gsub("[[:punct:]]", "", New2$text)
New2$text = gsub("[[:digit:]]", "", New2$text)
New2$text = gsub("[ \t]{2,}", "", New2$text)
New2$text = gsub("^\\s+|\\s+$", "", New2$text)
New2$text <- iconv(New2$text, "UTF-8", "ASCII", sub="")
New2$text<- removeWords(New2$text, stopwords("en"))

New3 <- pdata3%>%collect() 

New3$text=gsub("http\\w+", "", New3$text)  
New3$text=gsub("&amp", "", New3$text)
New3$text = gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", New3$text)
New3$text = gsub("@\\w+", "", New3$text)
New3$text = gsub("[[:punct:]]", "", New3$text)
New3$text = gsub("[[:digit:]]", "", New3$text)
New3$text = gsub("[ \t]{2,}", "", New3$text)
New3$text = gsub("^\\s+|\\s+$", "", New3$text)
New3$text <- iconv(New3$text, "UTF-8", "ASCII", sub="")
New3$text<- removeWords(New3$text, stopwords("en"))

# lexicon algorithm for sentiment analysis
library(syuzhet)

# sentiment for UK
emotions <- get_nrc_sentiment(New$text)
Sentimentscores_new<-data.frame(colSums(emotions[,]))
names(Sentimentscores_new)<-"Score"
Sentimentscores_new<-cbind("sentiment"=rownames(Sentimentscores_new),Sentimentscores_new)
rownames(Sentimentscores_new)<-NULL

# sentiment for USA
emotions2 <- get_nrc_sentiment(New2$text)
Sentimentscores_new2<-data.frame(colSums(emotions2[,]))
names(Sentimentscores_new2)<-"Score"
Sentimentscores_new2<-cbind("sentiment"=rownames(Sentimentscores_new2),Sentimentscores_new2)
rownames(Sentimentscores_new2)<-NULL

# sentiment for CANADA
emotions3 <- get_nrc_sentiment(New3$text)
Sentimentscores_new3<-data.frame(colSums(emotions3[,]))
names(Sentimentscores_new3)<-"Score"
Sentimentscores_new3<-cbind("sentiment"=rownames(Sentimentscores_new3),Sentimentscores_new3)
rownames(Sentimentscores_new3)<-NULL

# data can show as a table view
View(Sentimentscores_new)
View(Sentimentscores_new2)
View(Sentimentscores_new3)

# sentimenal point insert into new mongo db collection
ukdbplot <- mongo(collection = "ukplot",
              db = "ukdata",
              url = "mongodb://localhost")

usadbplot <- mongo(collection = "usaplot",
               db = "usadata",
               url = "mongodb://localhost")

canadadbplot <- mongo(collection = "canadaplot",
                  db = "canadadata",
                  url = "mongodb://localhost")

# data inserted into the mongodb
ukdbplot$insert(Sentimentscores_new)
usadbplot$insert(Sentimentscores_new2)
canadadbplot$insert(Sentimentscores_new3)

# diconnect spark
spark_disconnect(sc)  

source("dtvisualize.R")











