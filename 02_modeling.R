# Modeling - create n-gram models to be used for Word Prediction App
#
# 1. Clean up text - remove numbers, punctuation, symbols, etc., 
#    and remove stopwords. 
# 2. Remove profanity words. Profanity Words list is from Luis von Ahn’s research group 
#    at CMU (http://www.cs.cmu.edu/~biglou/resources/).
# 3. Generate document frequency matrix for unigram, bigram, trigram and quadgram
#    based on training data.
# 4. Compute maximum likelihood estimate (MLE) for unigram, bigram, trigram and quadgram.
# 5. Remove ngrams that only occur once.
# 6. Save the ngram models that will be used by the word prediction app.
#    
# =======================================================================================

library(data.table)
library(quanteda)
library(dplyr)

# Set seed for reproducibility 
set.seed(2468)

# Read in corpus created from sample data
modelCorpus <- readRDS("modelCorpus.rds")

# Load list of profanity words to be removed
profanityWords <- readLines('./data/profanity_words.txt')

# Create a document-feature matrix (dfm) 
# Using the Quanteda's dfm(), which applies certain options by default, such as tolower()

# Function to convert corpus to dfm
dfmNgram <- function(textObj, ngram) {
    outdfm <- textObj %>% 
        tokens(what = "word1",
               remove_punct = TRUE, 
               remove_numbers = TRUE, 
               remove_separators = TRUE, 
               remove_symbols = TRUE,
               remove_url = TRUE,
               split_hyphens = TRUE) %>%  
        tokens_remove(stopwords("english")) %>% 
        tokens_remove(profanityWords) %>%
        tokens_ngrams(n = ngram) %>% 
        dfm()
    return(outdfm)
}

# Function to create data table of terms and frequencies
ngramFreq <- function(rawDFM) {
    Freq <- colSums(rawDFM)
    return(data.table(term = names(Freq), freq = Freq))
}

# Generate unigrams and their frequency of occurence in the corpus
unigramDFM <- dfmNgram(modelCorpus, 1)
unigramFreq <- ngramFreq(unigramDFM)
rm(unigramDFM)

# Generate bigrams and their frequency 
bigramDFM <- dfmNgram(modelCorpus, 2)
bigramFreq <- ngramFreq(bigramDFM)
rm(bigramDFM)

#Generate trigrams and their frequency 
trigramDFM <- dfmNgram(modelCorpus, 3)
trigramFreq <- ngramFreq(trigramDFM)
rm(trigramDFM)

#Generate quadgrams and their frequency 
quadgramDFM <- dfmNgram(modelCorpus, 4)
quadgramFreq <- ngramFreq(quadgramDFM)
rm(quadgramDFM)

# Divide quadgram into trigram and unigram
quadgramFreq$term <- gsub("_", " ", quadgramFreq$term)
quadgramFreq$Prev <- gsub("^((\\w+\\W+){2}\\w+).*$", "\\1", quadgramFreq$term)
quadgramFreq$Next <-  gsub("^.* (\\w+|<e>)$", "\\1", quadgramFreq$term)
format(object.size(quadgramFreq), units = "Mb")

# Divide trigram into bigram and unigram
trigramFreq$term <- gsub("_", " ", trigramFreq$term)
trigramFreq$Prev <- gsub("^((\\w+\\W+){1}\\w+).*$", "\\1", trigramFreq$term)
trigramFreq$Next <-  gsub("^.* (\\w+|<e>)$", "\\1", trigramFreq$term)
format(object.size(trigramFreq), units = "Mb")

## Extract Previous and Next words from Bigram
bigramFreq$term <- gsub("_", " ", bigramFreq$term)
bigramFreq$Prev <- gsub("^(\\w+|<s>) .*$", "\\1", bigramFreq$term)
bigramFreq$Next <-  gsub("^.* (\\w+|<e>)$", "\\1", bigramFreq$term)
format(object.size(bigramFreq), units = "Mb")

# Generate quadgram probabilities using MLE 
quadgramProb <- inner_join(quadgramFreq, trigramFreq, by=c("Prev"="term"))
quadgramProb <- quadgramProb[,1:5]
names(quadgramProb) <- c( "Quadgram", "QuadgramFreq", "Trigram", "Next", "TrigramFreq")
quadgramProb$MLEProb <- quadgramProb$QuadgramFreq/quadgramProb$TrigramFreq
format(object.size(quadgramProb), units = "Mb")

# Remove quadgrams with frequency less than 2 occurences in the corpus
quadgramProb <- filter(quadgramProb, QuadgramFreq > 1)

# Write quadgram model to file
saveRDS(quadgramProb, "NextWordPredictor/quadgramProb.rds")

# Clean Up
rm(quadgramFreq, quadgramProb)

# Generate Trigram probabilities using MLE 
trigramProb <- inner_join(trigramFreq, bigramFreq, by=c("Prev"="term"))
trigramProb <- trigramProb[,1:5]
names(trigramProb) <- c("Trigram", "TrigramFreq", "Bigram", "Next", "BigramFreq")
trigramProb$MLEProb <- trigramProb$TrigramFreq/trigramProb$BigramFreq
format(object.size(trigramProb), units = "Mb")

# Remove trigrams with frequency less than 2 occurences in the corpus
trigramProb <- filter(trigramProb, TrigramFreq>1)

# Write Trigram model to file
saveRDS(trigramProb, "NextWordPredictor/trigramProb.rds")

# Clean Up
rm(trigramFreq, trigramProb)

## Generate Bigram Probabilities using MLE
bigramProb <- inner_join(bigramFreq, unigramFreq, by=c("Prev"="term"))
names(bigramProb) <- c("Bigram", "BigramFreq", "Prev", "Next", "PrevFreq")
bigramProb$MLEProb <- bigramProb$BigramFreq/bigramProb$PrevFreq
format(object.size(bigramProb), units = "Mb")

# Remove bigrams with frequency less than 2 occurences in the corpus
bigramProb <- filter(bigramProb, BigramFreq>1)

#Generate unigram probabilities using MLE
unigramProb <- select(unigramFreq, term, freq) %>% 
    mutate(MLEProb = freq/sum(unigramFreq$freq))

# Calculate Kneser-Ney Continuation for Unigram

#Using bigram Probabilities table, find the number of bigrams preceeding each word
prevWordCount <- group_by(bigramProb, Next) %>% 
    summarize(PrevCount=n()) %>% 
    arrange(desc(PrevCount))
unigramProb <- left_join(unigramProb, prevWordCount, by=c("term"="Next"))
unigramProb$KNProb <- unigramProb$PrevCount/nrow(bigramProb)
names(unigramProb) <- c( "Next", "Freq", "MLEProb", "PrevCount", "KNProb")

#Write computed Bigram and Unigram probabilities into files
saveRDS(unigramProb, "NextWordPredictor/unigramProb.rds")
saveRDS(bigramProb, "NextWordPredictor/bigramProb.rds")

#Clean Up
rm(unigramProb, unigramFreq, bigramProb, bigramFreq, prevWordCount)


