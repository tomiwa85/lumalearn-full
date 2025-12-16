import sys
import os
from unittest.mock import MagicMock

# Mock dependencies before importing the module
sys.modules["services.groq_service"] = MagicMock()
sys.modules["services.rag_service"] = MagicMock()
sys.modules["core.database"] = MagicMock()

# Setup specific mocks
sys.modules["services.groq_service"].get_groq_response.return_value = "This is a mock AI response."
sys.modules["services.rag_service"].retrieve_context.return_value = "Mock context."

# Mock Supabase client
mock_supabase = MagicMock()
sys.modules["core.database"].supabase = mock_supabase
# Mock the chain: supabase.table().select().eq().order().limit().execute()
mock_supabase.table.return_value.select.return_value.eq.return_value.order.return_value.limit.return_value.execute.return_value.data = []

# Now import the function to test
from services.tutor_engine import process_student_message

def test_process_student_message():
    print("Testing process_student_message...")
    session_id = "test_session"
    user_message = "Hello"
    subject = "Math"

    response = process_student_message(session_id, user_message, subject)
    
    print(f"Response received: {response}")
    
    if response == "This is a mock AI response.":
        print("SUCCESS: Logic executed correctly.")
    else:
        print("FAILURE: Unexpected response.")

    # Verify NO inserts happened
    # We expect 0 calls to insert because we commented them out
    insert_calls = mock_supabase.table.return_value.insert.call_count
    if insert_calls == 0:
        print("SUCCESS: No database inserts detected (as expected).")
    else:
        print(f"FAILURE: Database inserts detected! Count: {insert_calls}")

if __name__ == "__main__":
    test_process_student_message()
