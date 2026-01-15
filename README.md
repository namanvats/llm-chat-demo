### LLM Chat API Demo
This is a simple FastAPI-powered LLM Chat API demo. The server acts as a wrapper around OpenAI models to provide conversational capabilities via a REST API.

#### Setups
Go to root directory

- pip install -r requirements.txt
- uvicorn app.main:app --reload --host 0.0.0.0 --port 8000