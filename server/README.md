# Emotion Detection API

A FastAPI server that detects emotions in text using the GoEmotions model.

## Setup

1. Create a virtual environment (recommended):
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

   Note: This will download the GoEmotions model (approximately 1.5GB) on first run.

## Running the Server

```bash
uvicorn main:app --reload
```

The server will start at `http://127.0.0.1:8000`

## API Endpoints

### Detect Emotions

- **URL**: `/emotion`
- **Method**: `POST`
- **Content-Type**: `application/json`

**Request Body**:
```json
{
  "text": "your text here",
  "threshold": 0.3
}
```

**Parameters**:
- `text` (required): The text to analyze
- `threshold` (optional, default=0.3): Confidence threshold (0-1) for emotion detection

**Example Response**:
```json
[
  {
    "emotion": "anger",
    "score": 0.876
  },
  {
    "emotion": "annoyance",
    "score": 0.754
  }
]
```

## Interactive Documentation

Once the server is running, you can access:
- Interactive API docs: http://127.0.0.1:8000/docs
- Alternative API docs: http://127.0.0.1:8000/redoc
