from transformers import AutoTokenizer, AutoModelForSequenceClassification
import torch
from typing import List,Dict, Any
from concurrent.futures import ThreadPoolExecutor
from pydantic import BaseModel


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
class QAPair(BaseModel):
    question: str
    answer: str
    emotions: List[Dict[str, Any]] = []

def predict_emotions(text, threshold=0.3):
    # Tokeniza entrada
    inputs = tokenizer(text, return_tensors="pt", truncation=True, padding=True)
    outputs = model(**inputs)

    # Sigmoid para multilabel
    probs = torch.sigmoid(outputs.logits)[0].detach().numpy()

    # Filtra emoções com probabilidade acima do limiar
    detected = [(labels[i], round(float(probs[i]), 3)) for i in range(len(labels)) if probs[i] > threshold]
    return detected

def process_qa_pairs(qa_pairs: List[QAPair], threshold: float = 0.3) -> List[QAPair]:
    """
    Processa uma lista de objetos QAPair em paralelo, adicionando emoções detectadas a cada um.
    
    Args:
        qa_pairs: Lista de QAPair contendo 'question' e 'answer'
        threshold: Limiar de confiança para considerar uma emoção detectada (padrão: 0.3)
        
    Returns:
        Lista de QAPair com a propriedade 'emotions' preenchida
    """
    def process_single(qa: QAPair) -> QAPair:
        emotions = predict_emotions(qa.answer, threshold)
        qa.emotions = [{"emotion": e[0], "score": e[1]} for e in emotions]
        return qa

    # Processa em paralelo
    with ThreadPoolExecutor() as executor:
        results = list(executor.map(process_single, qa_pairs))

    return [qa.model_dump() for qa in results]




