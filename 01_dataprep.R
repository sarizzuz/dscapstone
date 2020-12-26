## Data Prep - prepare sample data for creating n-gram models
##
## 1. Read in sample dataset based on a sample size and partition into training
##    and test sets
## 2. Remove non-ASCII characters from text
## 3. Tokenizes sample text into sentences.
## 4. Remove profanity words. Profanity Words list is from Luis von Ahn’s research group 
##    at CMU (http://www.cs.cmu.edu/~biglou/resources/).
## 
## Input Docs:
## Twitter text: final/en_US/en_US.twitter.txt
## Blog text: final/en_US/en_US.blogs.txt
## News text: final/en_US/en_US.news.txt
## Profanity filter: swearWords.txt
##
## Output Docs:
## Training data: sampleData.txt
## Test data: testData.txt
##
## =======================================================================================

library(quanteda)
library(dplyr)

# Set seed for reproducibility
set.seed(2468)

# Set sample size to be used
sampleSize <- .15

# Set size of test set as a percentage of the total sample
testSize <- .20

# File connections 
blogsfile <- "./data/final/en_US/en_US.blogs.txt"
newsfile <- "./data/final/en_US/en_US.news.txt"
twitterfile <- "./data/final/en_US/en_US.twitter.txt"

# Read in data
blogsData <- readLines(blogsfile, skipNul = TRUE, warn = FALSE)
newsData <- readLines(newsfile, skipNul = TRUE, warn = FALSE)
twitterData <- readLines(twitterfile, skipNul = TRUE, warn = FALSE)

# Sample blogs data
sample <- as.logical(rbinom (n=length(blogsData),size=1, prob = sampleSize))
sampleBlogs <- blogsData[sample]
# Set aside text for testing
test <- as.logical(rbinom (n=length(sampleBlogs),size=1, prob = testSize))
testBlogs <- sampleBlogs[test]
# Set aside text for training model
modelBlogs <- sampleBlogs[!test]
rm(blogsData, sampleBlogs)

# Sample news data
sample <- as.logical(rbinom (n=length(newsData),size=1, prob = sampleSize))
sampleNews <- newsData[sample]
# Set aside text for testing
test <- as.logical(rbinom (n=length(sampleNews),size=1, prob = testSize))
testNews <- sampleNews[test]
# Set aside text for training model
modelNews <- sampleNews[!test]
rm(newsData, sampleNews)

# Sample twitter data
sample <- as.logical(rbinom (n=length(twitterData),size=1, prob = sampleSize))
sampleTweets <- twitterData[sample]
# Set aside text for testing
test <- as.logical(rbinom (n=length(sampleTweets),size=1, prob = testSize))
testTweets <- sampleTweets[test]
# Set aside text for training model
modelTweets <- sampleTweets[!test]
rm(twitterData, sampleTweets, test, sample)

# Combine the model datasets and test datasets
modelData <- c(modelTweets, modelBlogs, modelNews)
testData <- c(testTweets, testBlogs, testNews)

# Save  test dataset to file for later use
write.table(testData, "./data/testData.txt", col.names = FALSE, row.names = FALSE, quote=FALSE)

# Clean up environment
rm(modelTweets, modelBlogs, modelNews)
rm(testTweets, testBlogs, testNews, testData)

# Remove non-ASCII characters
modelData <- iconv(modelData, "latin1", "ASCII", sub="")

# Convert data into a corpus
modelCorpus <- corpus(modelData)

# Save Corpus
saveRDS(modelCorpus, file = "modelCorpus.rds")


# Clean up environment
rm(modelData, modelCorpus)


# Save sample dataset to file for later use
#write.table(sampleSentences, "./data/sampleData.txt", col.names = FALSE, row.names = FALSE, quote=FALSE)

