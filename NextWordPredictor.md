NextWordPredictor App
========================================================
author: Farah M
date: December 2020
autosize: true

The App
========================================================

Next Word Predictor is a Shiny app that uses a text prediction algorithm to predict the next word based on text that is entered by the user.

<small>
It was developed for the Capstone Project for the Data Science Specialization by Johns Hopkins University in Coursera and is accessible through the link:
<https://sarizzuz.shinyapps.io/NextWordPredictor/>

The R codes for the application are available in:
<https://github.com/sarizzuz/nextwordpredictor/tree/main/NextWordPredictor>

The main repository containing the R codes for generating the models used for prediction along with other materials created for the capstone project:
<https://github.com/sarizzuz/nextwordpredictor>

</small>


User Interface
========================================================
<small>
The App has a simple and intuitive user interface.

On the "App" tab, the user enters the word or phrase in the "Input Box".

Within a few seconds the suggested next words will appear in the "Output Box".
</small>

![Word Prediction App](NextWordPredictor UI.png) 


Under The Hood
========================================================
The maximum likelihood estimation or MLE is used to estimate the probabilities that is assigned to the N-gram models. Then the Stupid Back-off algorithm is applied to get the next word prediction. Finally, the Kneser-Ney smoothing is used when there is insufficient match results.

For this application, the n-grams used are: quadgrams, trigrams, bigrams and unigrams. 
The n-grams models created from samples of twitter, blog and news text taken from a corpus called HC Corpora. 

References Used 
========================================================
<small>
Natural Language Processing resources:

+  [Text mining infrastucture in R]("http://www.jstatsoft.org/v25/i05/")
+  [CRAN Task View: Natural Language Processing]("http://cran.r-project.org/web/views/NaturalLanguageProcessing.html")
+  [Videos]("https://www.youtube.com/user/OpenCourseOnline/search?query=NLP") and [Slides]("https://web.stanford.edu/~jurafsky/NLPCourseraSlides.html") from Stanford Natural Language Processing course
+ [Stupid Back-Off Algorithm](http://www.aclweb.org/anthology/D07-1090.pdf)
+ [Wikipedia: Natural Language Processing](https://en.wikipedia.org/wiki/Natural-language_processing)

Text Mining
+ [Wikipedia: Text Mining](https://en.wikipedia.org/wiki/Text_mining)
+ [Coursera: Text Mining and Analytics Course](https://www.coursera.org/learn/text-mining)
+ [statsoft.com: Text Mining](http://www.statsoft.com/Textbook/Text-Mining)
</small>
