#textblob library
#create a sample text

from textblob import TextBlob


texts = [
"I love NLP ! It's works great and I'm very satisfied",
"This my first experince on doing sentiment analysis, I am littile bit disappointed",
"The NLP sentiment analysis is quiet intreseting it is neither good or bad",
]
#create function to do the sentiment analysis
def analyze_sentiment(text):
     analysis = TextBlob(text)
     polarity=analysis.sentiment.polarity
     if polarity>0:
         sentiment="Positive"
     elif polarity<0:
         sentiment="Negative"
     else:
         sentiment="Neutral"
     return sentiment        

for text in texts:
    sentiment=analyze_sentiment(text)
    print(f"Text:{text}\n")
    print(f"Sentiment:{sentiment}\n")     