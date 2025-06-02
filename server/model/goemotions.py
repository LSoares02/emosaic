from transformers import AutoTokenizer, AutoModelForSequenceClassification
import torch

# Carrega tokenizer e modelo
model_name = "monologg/bert-base-cased-goemotions-original"
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForSequenceClassification.from_pretrained(model_name)

# Emoções (27 + neutro), mesma ordem usada no modelo
labels = [
    "admiration", "amusement", "anger", "annoyance", "approval", "caring",
    "confusion", "curiosity", "desire", "disappointment", "disapproval",
    "disgust", "embarrassment", "excitement", "fear", "gratitude", "grief",
    "joy", "love", "nervousness", "optimism", "pride", "realization", "relief",
    "remorse", "sadness", "surprise", "neutral"
]

def predict_emotions(text, threshold=0.3):
    # Tokeniza entrada
    inputs = tokenizer(text, return_tensors="pt", truncation=True, padding=True)
    outputs = model(**inputs)

    # Sigmoid para multilabel
    probs = torch.sigmoid(outputs.logits)[0].detach().numpy()

    # Filtra emoções com probabilidade acima do limiar
    detected = [(labels[i], round(float(probs[i]), 3)) for i in range(len(labels)) if probs[i] > threshold]
    return detected

# text = "Sad stuff, but I remain optimistic as ever!"
# result = predict_emotions(text)
# print("Emoções detectadas:", result)
