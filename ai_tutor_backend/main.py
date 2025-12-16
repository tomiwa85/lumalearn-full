
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from services.groq_service import get_groq_response
# Import other services as needed

app = FastAPI(title="AI Tutor Agent Backend")

class ChatRequest(BaseModel):
    session_id: str
    message: str
    subject: str = "General"

@app.get("/")
def read_root():
    return {"message": "AI Tutor Agent Backend is running."}

@app.post("/chat")
def chat_endpoint(request: ChatRequest):
    from services.tutor_engine import process_student_message
    
    # Check if session exists, if not create it (simplified logic)
    # Ideally, the client sends a valid session_id or we create one here.
    # For now, we assume the client manages session_ids or we auto-create if missing.
    try:
        # Quick check or upsert session
        # supabase.table("sessions").upsert({"id": request.session_id, "subject": request.subject}).execute()
        # Ignoring for speed, but ideally we ensure referential integrity.
        pass
    except:
        pass

    response_text = process_student_message(request.session_id, request.message, request.subject)
    
    return {"response": response_text}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
