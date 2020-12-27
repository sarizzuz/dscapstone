# Prediction Model - next word predictor 
#
# 1. Load ngram models into R. 
# 2. Function predicts next word based on stupid backoff model.
# 3. Remove non-ASCII characters from text
# 4. Save model corpus
# 
# =======================================================================================

## Function that predicts next word based on stupid backoff model but using 
## kneser-ney probability when it reaches unigram
##

library(data.table)
library(dplyr)
library (quanteda)

# Read in ngram models
UnigramProb <- readRDS("./NextWordPredictor/unigramProb.rds")
BigramProb <- readRDS("./NextWordPredictor/bigramProb.rds")
TrigramProb <- readRDS("./NextWordPredictor/trigramProb.rds")
QuadgramProb <- readRDS("./NextWordPredictor/quadgramProb.rds")

# Function for predicting next words using ngram models created in 02_modeling.R
predictNextWord <- function(inputText, choices=NULL) {
    
    # Replicate training set pre-process for input text
    cleanText <- inputText %>% 
        tokens(what = "word1",
               remove_punct = TRUE, 
               remove_numbers = TRUE, 
               remove_separators = TRUE, 
               remove_symbols = TRUE,
               remove_url = TRUE,
               split_hyphens = TRUE) %>%
        tokens_tolower() %>%
        as.list()
        
    # Check if input text is valid and display a message
    txt <- cleanText$text1
    num <- length(cleanText$text1)
    
    if (num == 0) {
        return("App is ready. Please enter a word or phrase to begin.")
    } else {
        #Start Predicting Next Word
        
        #Initialize empty data frame to hold the next word predictions
        match <- data.table(Next=character(), MLEProb=numeric())
        
        #Attempt to match to a quadgram if sentence has 3 or more words using MLE 
        if (num >= 3) {
            lastTrigram <- paste0(txt[num-2], " ",
                                  txt[num-1], " ", 
                                  txt[num])
            match <- filter(QuadgramProb, lastTrigram==Trigram) %>% select(Next, MLEProb)
        }
        
        #If sentence has only 2 words or if match has less than 5 results
        if (num >= 2 | nrow(match) < 5) {
            lastBigram <- paste0(txt[num-1], " ", 
                                 txt[num])
            x <- filter(TrigramProb, lastBigram==Bigram) %>% 
                select(Next, MLEProb) %>% mutate(MLEProb=MLEProb*0.4) 
            match <- filter(x, !(Next %in% match$Next)) %>% bind_rows(match)
        }
        
        #If sentence has only 1 word or if match has less than 5 results
        if (num == 1 | nrow(match) < 5){
            lastWord <- txt[num]
            x <- filter(BigramProb, lastWord==Prev) %>% 
                select(Next, MLEProb) %>% mutate(MLEProb=MLEProb*0.4*0.4)
            match <- filter(x, !(Next %in% match$Next)) %>% bind_rows(match)
        } 
        
        #If Bigram match has failed, if match has less than 5 results
        if (nrow(match) < 0){
            x <- top_n(UnigramProb, 5, KNProb) %>% select(Next, KNProb) %>% 
                mutate(MLEProb=KNProb*0.4*0.4*0.4)
            match <- filter(x, !(Next %in% match$Next)) %>% bind_rows(match)
        } 
        
        #filter top match based on choices provided
        if (!is.null(choices)) {
            match <- filter(match, Next %in% choices)
        }
        
        #Sort matches by MLE
        match <- arrange(match, desc(MLEProb))
        
        return(paste0(inputText, " ", head(match$Next, 1)))
    }
}