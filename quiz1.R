#Qn1:
# The en_US.blogs.txt file is how many megabytes? 200

#Qn2:
# The en_US.twitter.txt has how many lines of text?

#load data
twitterEN <- readLines("./data/final/en_US/en_US.twitter.txt")
length(twitterEN)
 
#Qn3:
#What is the length of the longest line seen in any of the three en_US data sets?
blog_lines <- nchar(readLines("./data/final/en_US/en_US.blogs.txt"))
max(blog_lines)

news_lines <- nchar(readLines("./data/final/en_US/en_US.news.txt"))
max(news_lines)

twitter_lines <- nchar(readLines('./data/final/en_US/en_US.twitter.txt'))
max(twitter_lines)

#Qn4:
# In the en_US twitter data set, if you divide the number of lines where the word "love" 
# (all lowercase) occurs by the number of lines the word "hate" (all lowercase) occurs, 
# about what do you get?

twitter_love_set <- grepl("love", twitterEN)
twitter_hate_set <- grepl("hate", twitterEN)
twitter_ratio <- sum(twitter_love_set) / sum(twitter_hate_set)
twitter_ratio
# 4.108592

#Qn5:
# The one tweet in the en_US twitter data set that matches the word "biostats" says what?


subset(twitterEN, grepl("biostats", twitterEN))
# [1] "i know how you feel.. i have biostats on tuesday and i have yet to study =/"

grep("A computer once beat me at chess, but it was no match for me at kickboxing", twitterEN)
