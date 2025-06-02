from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from model.goemotions import predict_emotions
from pydantic import BaseModel
from typing import List, Tuple

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

class TextInput(BaseModel):
    text: str
    threshold: float = 0.3

@app.post("/emotion", response_model=List[EmotionResponse])
async def detect_emotion(data: TextInput):
    """
    Detect emotions in the given text.
    
    - **text**: The input text to analyze
    - **threshold**: Confidence threshold (0-1) for emotion detection (default: 0.3)
    """
    try:
        emotions = predict_emotions(data.text, data.threshold)
        return [{"emotion": e[0], "score": e[1]} for e in emotions]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/")
async def root():
    return {"message": "Emotion Detection API is running. Use POST /emotion to detect emotions in text."}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
