library(readtext)
library(quanteda)
library(spacyr)
library(data.table)
library(tidyr)
library(dplyr)
library(ggplot2)
set.seed(158)
spacy_initialize()
setwd("C:/Users/rjull/OneDrive/Coursera/10 - Capstone Project/final")
txtRead <- readtext("en_US/*.txt",
                    docvarsfrom = "filenames",
                    docvarnames = c("lang","src"),
                    dvsep = "_")

##Create corpus
txtCor <- corpus(txtRead)
#Sentences
corpsent <- corpus_reshape(txtCor, to = "sentence")
##Sample and Create Train & Test
#Create id
docvars(corpsent, "id_numeric") <- 1:ndoc(corpsent)
#Generate sample ids
id_train <- sample(1:ndoc(corpsent), 0.7*ndoc(corpsent), replace = FALSE)
#Test & Train corpus
corpTrain <- corpus_subset(corpsent, id_numeric %in% id_train)
corpTest <- corpus_subset(corpsent, !id_numeric %in% id_train)

#Tokenize Corpus for ngram
corpTrainTok <- tokens(corpTrain, remove_symbols = T, remove_punct = T, remove_url = T)

#DFM of ngrams
dfmTrain1n <- tokens_ngrams(corpTrainTok, n = 1) %>% dfm()
dfmTrain2n <- tokens_ngrams(corpTrainTok, n = 2) %>% dfm()
dfmTrain3n <- tokens_ngrams(corpTrainTok, n = 3) %>% dfm()
dfmTrain4n <- tokens_ngrams(corpTrainTok, n = 4) %>% dfm()
dfmTrain5n <- tokens_ngrams(corpTrainTok, n = 5) %>% dfm()

#Trim DFM to remove low frequency
train1nTrimed <- dfm_trim(dfmTrain1n, min_termfreq = .98, termfreq_type = 'quantile')
train2nTrimed <- dfm_trim(dfmTrain2n, min_termfreq = .98, termfreq_type = 'quantile')
train3nTrimed <- dfm_trim(dfmTrain3n, min_termfreq = .98, termfreq_type = 'quantile')
train4nTrimed <- dfm_trim(dfmTrain4n, min_termfreq = .98, termfreq_type = 'quantile')
train5nTrimed <- dfm_trim(dfmTrain5n, min_termfreq = .98, termfreq_type = 'quantile')

#90percentile trimmed nothing
#99 trimmed a lot
#98 Best compromise
#97 looks promising
#95 don't trim 5n

#Create DT
#1n
tab1n <- as.data.frame(topfeatures(train1nTrimed,length(train1nTrimed)))
tab1n[,2] <- tab1n[,1]
tab1n[,1] <- rownames(tab1n)
rownames(tab1n) <- NULL
colnames(tab1n) <- c("grams","count")

#2n
tab2n <- as.data.frame(topfeatures(train2nTrimed,length(train2nTrimed)))
tab2n[,2] <- tab2n[,1]
tab2n[,1] <- rownames(tab2n)
rownames(tab2n) <- NULL
colnames(tab2n) <- c("grams","count")

#3n
tab3n <- as.data.frame(topfeatures(train3nTrimed,length(train3nTrimed)))
tab3n[,2] <- tab3n[,1]
tab3n[,1] <- rownames(tab3n)
rownames(tab3n) <- NULL
colnames(tab3n) <- c("grams","count")

#4n
tab4n <- as.data.frame(topfeatures(train4nTrimed,length(train4nTrimed)))
tab4n[,2] <- tab4n[,1]
tab4n[,1] <- rownames(tab4n)
rownames(tab4n) <- NULL
colnames(tab4n) <- c("grams","count")

#5n
tab5n <- as.data.frame(topfeatures(train5nTrimed,length(train5nTrimed)))
tab5n[,2] <- tab5n[,1]
tab5n[,1] <- rownames(tab5n)
rownames(tab5n) <- NULL
colnames(tab5n) <- c("grams","count")

#Treat dataframe
colnames(tab1n)[1] <- "given"
tab2n <- tab2n %>% separate(grams,c("given","pred"), sep = "_", extra = "merge")
tab3n <- tab3n %>% 
  separate(grams,c("n1","n2","pred"), sep = "_", extra = "merge") %>%
  unite(col = "given", c("n1","n2"), sep = "_")
tab4n <- tab4n %>% 
  separate(grams,c("n1","n2","n3","pred"), sep = "_", extra = "merge") %>%
  unite(col = "given", c("n1","n2","n3"), sep = "_")
tab5n <- tab5n %>% 
  separate(grams,c("n1","n2","n3","n4","pred"), sep = "_", extra = "merge") %>%
  unite(col = "given", c("n1","n2","n3","n4"), sep = "_")


#Set DT
tab1n <- setDT(tab1n)
tab2n <- setDT(tab2n)
tab3n <- setDT(tab3n)
tab4n <- setDT(tab4n)
tab5n <- setDT(tab5n)

#Put into a list
allN <- list(tab1n,tab2n,tab3n,tab4n,tab5n)

#Set key
allN[[1]] <- setkey(allN[[1]],given)
allN[[2]] <- setkeyv(allN[[2]],c("given","pred"))
allN[[3]] <- setkeyv(allN[[3]],c("given","pred"))
allN[[4]] <- setkeyv(allN[[4]],c("given","pred"))
allN[[5]] <- setkeyv(allN[[5]],c("given","pred"))

#Run for cleaning
rm(tab1n,tab2n,tab3n,tab4n,tab5n,train1nTrimed,train2nTrimed,train3nTrimed,train4nTrimed,train5nTrimed)
