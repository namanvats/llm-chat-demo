from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from openai import OpenAI
from dotenv import load_dotenv
import os
import datetime
import time

load_dotenv()

app = FastAPI(
    title="LLM API Service for Masai",
    description="API for Masai's LLM service",
    version="1.0.0",
    contact={
        "name": "Masai School",
        "url": "https://masaischool.com",
        "email": "contact@masaischool.com",
    },
    license_info={
        "name": "MIT License",
    }
)

# Config Setup for OpenAI
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
if not OPENAI_API_KEY:
    raise ValueError("OPENAI_API_KEY is not set")

client = OpenAI(api_key=OPENAI_API_KEY)
LLM_MODEL = os.getenv("LLM_MODEL", "gpt-4o-mini")

#Prompt for model
prompt = """
"You are a helpful assistant that can answer questions and help with tasks."
"""

#Models
class ChatRequest(BaseModel):
    user_id: str
    message: str

class ChatResponse(BaseModel):
    reply: str
    latency_ms: float
    model: str
    prompt_tokens: int
    completion_tokens: int
    user_id: str

@app.get("/health")
async def health_check():
    return {
        "status": "ok",
        "model": LLM_MODEL,
        "timestamp": datetime.datetime.now(datetime.UTC).isoformat()
    }

@app.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    print(f"Received request from user {request.user_id}: {request.message}")
    full_prompt = f"{prompt}\n\nUser: {request.message}\nAssistant:"
    start_time = time.time()
    try:
        response = client.chat.completions.create(
            model=LLM_MODEL,
            messages=[{"role": "user", "content": full_prompt}],
            temperature=0.5,
            max_completion_tokens=500,
            timeout=30.0
        )
        end_time = time.time()
        latency_ms = (end_time - start_time) * 1000
        reply = response.choices[0].message.content
        prompt_tokens = response.usage.prompt_tokens
        completion_tokens = response.usage.completion_tokens
        return ChatResponse(
            reply=reply,
            latency_ms=latency_ms,
            model=LLM_MODEL,
            prompt_tokens=prompt_tokens,
            completion_tokens=completion_tokens,
            user_id=request.user_id
        )
    except Exception as e:
        print(f"Error processing request from user {request.user_id}: {str(e)}")
        raise HTTPException (
            status_code=500, 
            detail=f"LLM Request Failed, Internal Server Error: {str(e)}",
        )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)