import nltk 
from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, classification_report

# Create a larger sample dataset
data = [("I love NLP", "Positive"),
        ("I hate this technology", "Negative"),
        ("It's okay, nothing special", "Neutral"),
        ("NLP is amazing", "Positive"),
        ("I dislike this approach", "Negative"),
        ("The results are good", "Positive"),
        ("This is not good", "Negative"),
        ("I am happy with the outcome", "Positive"),
        ("I am not happy with the outcome", "Negative"),
        ("It's an average performance", "Neutral")]

# Separate all the sentences and labels
sentences, labels = zip(*data)

nltk.download("punkt")
nltk.download("stopwords")

# Initialize the stopwords with the English language
stop_words = set(stopwords.words("english"))

def preprocess(text):
    tokens = word_tokenize(text.lower())
    # Remove stop words and punctuation
    filtered_tokens = [word for word in tokens if word.isalnum() and word not in stop_words]
    return " ".join(filtered_tokens)

# Preprocess the sentences
preprocessed_sentences = [preprocess(sentence) for sentence in sentences]

# Feature extraction
vectorizer = TfidfVectorizer()
# Fit and transform the data with the TfidfVectorizer
x = vectorizer.fit_transform(preprocessed_sentences)

# Split the data using stratified sampling
x_train, x_test, y_train, y_test = train_test_split(x, labels, test_size=0.5, random_state=42, stratify=labels)

# Train the model with the Naive Bayes classifier
classifier = MultinomialNB()
classifier.fit(x_train, y_train)

# Predict the labels for the test set
y_pred = classifier.predict(x_test)

# Evaluate the model
accuracy = accuracy_score(y_test, y_pred)
report = classification_report(y_test, y_pred, zero_division=1)

print(f"Accuracy: {accuracy}")
print(f"Classification report:\n{report}")
