import pytest
from app.main import prompt, LLM_MODEL

class TestPromptQuality:
    def test_prompt_exists(self):
        assert prompt is not None
        assert len(prompt.strip()) > 0
        print(f"Prompt exists and is not empty")
    
    def test_prompt_reasonable(self):
        word_count = len(prompt.split())
        assert word_count < 200
        print(f"Prompt is reasonable with {word_count} words")
    
    def test_prompt_no_secret(self):
        dangerous_words = ["api", "key", "secret", "sk-", "openai", "openai-api-key", "OPENAI_API_KEY"]
        prompt_lower = prompt.lower()
        for word in dangerous_words:
            assert word not in prompt_lower, f"Prompt contains dangerous word"
        print(f"Prompt does not contain dangerous words")
    
    def test_valid_model(self):
        valid_models = ["gpt-4o-mini", "gpt-4o", "gpt-3.5-turbo", "gpt-3.5-turbo-1106"]
        assert LLM_MODEL in valid_models, f"Invalid model: {LLM_MODEL}"
        print(f"Valid model: {LLM_MODEL}")