
import uuid
from services.tutor_engine import process_student_message

def run_cli_chat():
    session_id = str(uuid.uuid4())
    print(f"Starting new chat session: {session_id}")
    print("Type 'quit' to exit.")
    
    while True:
        user_input = input("\nYou: ")
        if user_input.lower() in ["quit", "exit"]:
            break
            
        print("Tutor is thinking...")
        try:
            response = process_student_message(session_id, user_input, "Math")
            print(f"Tutor: {response}")
        except Exception as e:
            print(f"Error: {e}")
            print("Ensure Supabase tables are created and .env is set.")

if __name__ == "__main__":
    run_cli_chat()
