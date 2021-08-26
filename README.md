# Predicting Next Word - Using R and Swiftkey Database
This project is a part of the Coursera's Data Science Specialization. I named it "You Type, I Predict.".

## Goals of this project
- Explore the methods of natural langauge processing.
- Create a next word prediction algorithm based on the provided corpus and existed research.
- Deploy said algorithm through a web application environment.
- Hope that it helps me pass the capstone.

## File Directory
- **server.R & ui.R** - The shiny application server and ui. 
- **newPredFunction2.R** - Prediction function used in the application.
- **CorpusAndDataPrep-Redo.R** - Data Treatment script (see Data Treatment section).
- **Q98TrainData.rds** - a RDS file containing the data used for prediction.

## Data Treatment
- The corpus, provided by the course, was divided to train and test* (70:30).
- Training dataset was then tokenized using [Quanteda](https://quanteda.io/) and puctuations, symbols and urls were removed.
- 5 ngrams dfms were created ranging from unigram, bigram to 5-grams.
- To have a feasible size of datasets for online environment, all dfms were trimmed leaving only the grams that occur at 98percentile and above.
- This resulted in about 35MBs of RDS file, which similar to a 5-minutes 720p Youtube video.
- Finally, the dfms were converted to [data.table](https://cran.r-project.org/web/packages/data.table/vignettes/datatable-intro.html) to prepare for a predicting algorithm.

## The Application - You Type, I Predict.
- The application can be accessed here: https://rchul.shinyapps.io/DS-Capstone-Predictor/.
- The application utilzed Stupid Back-off, which is the next word prediction algorithm proposed by [(T. Brants et al., 2007)](https://aclanthology.org/D07-1090.pdf)
- As the name of the application suggested, you only have to type, and 3 predictions will be presented.
- The middle one is the most likely one, similiar to your phone.
