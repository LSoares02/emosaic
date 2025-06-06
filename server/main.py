from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from model.goemotions import predict_emotions, process_qa_pairs
from pydantic import BaseModel
from typing import List, Dict, Any

app = FastAPI(title="Emotion Detection API",
             description="API for detecting emotions in text using GoEmotions model",
             version="1.0.0")

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class EmotionResponse(BaseModel):
    emotion: str
    score: float

class QAPair(BaseModel):
    question: str
    answer: str
    emotions: List[Dict[str, Any]] = []

class EmotionInput(BaseModel):
    entries: List[QAPair]
    threshold: float = 0.3

@app.post("/emotion", response_model=List[QAPair])
async def detect_emotion(data: EmotionInput):
    """
    Detect emotions in the given text.
    
    - **entries**: List of Q&A pairs
    - **threshold**: Confidence threshold (0-1) for emotion detection (default: 0.3)
    """
    try:
        updated_qa_pairs = process_qa_pairs(data.entries, data.threshold)
        print(updated_qa_pairs)
        return updated_qa_pairs
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/")
async def root():
    return {"message": "Emotion Detection API is running. Use POST /emotion to detect emotions in text."}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
