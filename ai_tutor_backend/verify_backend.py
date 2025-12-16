
import sys
import uuid
import time
from services.tutor_engine import process_student_message
from services.rag_service import generate_embedding

def verify_system():
    print("--- STARTING SYSTEM VERIFICATION ---")
    
    # 1. Test Embeddings
    print("\n[1] Testing Embedding Generation...")
    try:
        vec = generate_embedding("test")
        print(f"PASS: Generated embedding of length {len(vec)}")
        if len(vec) == 0 or (len(vec) == 384 and vec[0] == 0.0 and vec[1] == 0.0):
             print("WARNING: Embedding seems to be zero-vector (Model not loaded?). RAG will be weak.")
    except Exception as e:
        print(f"FAIL: Embedding generation error: {e}")
        return

    # 2. Test Tutor Logic (End-to-End)
    print("\n[2] Testing Grpoq + Tutor Logic...")
    session_id = str(uuid.uuid4())
    student_msg = "Solve 2 + 2"
    print(f"Student Message: {student_msg}")
    
    try:
        response = process_student_message(session_id, student_msg, "Math")
        print(f"\nTutor Response:\n{response}")
        
        if not response:
            print("FAIL: Empty response from Tutor Engine.")
        else:
            print("PASS: Received response from Tutor Engine.")
            
    except Exception as e:
        print(f"FAIL: Tutor Engine error: {e}")
        # Common errors: Supabase connection, Table not found, Groq API key
        if "relation" in str(e) and "does not exist" in str(e):
            print("HINT: Did you run the 'setup_database.sql' script in Supabase?")
        
    print("\n--- VERIFICATION COMPLETE ---")

if __name__ == "__main__":
    verify_system()
