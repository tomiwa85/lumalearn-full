
import os
from groq import Groq
from core.config import settings

client = Groq(
    api_key=settings.GROQ_API_KEY,
)

def get_groq_response(system_prompt: str, user_message: str, model: str = "llama-3.3-70b-versatile"):
    chat_completion = client.chat.completions.create(
        messages=[
            {
                "role": "system",
                "content": system_prompt,
            },
            {
                "role": "user",
                "content": user_message,
            }
        ],
        model=model,
    )
    return chat_completion.choices[0].message.content
