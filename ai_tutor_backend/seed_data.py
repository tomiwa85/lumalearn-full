
import json
from core.database import supabase
from services.rag_service import generate_embedding

# Sample Data for Math
sample_knowledge = [
    {
        "content": "Addition is the process of calculating the total of two or more numbers or amounts.",
        "metadata": {"subject": "Math", "topic": "Addition", "difficulty": "Beginner"}
    },
    {
        "content": "To add small numbers, you can count them one by one. For example, 2 apples + 2 apples = 4 apples.",
        "metadata": {"subject": "Math", "topic": "Addition", "difficulty": "Beginner"}
    },
    {
        "content": "The symbol for addition is '+'. It is called the plus sign.",
        "metadata": {"subject": "Math", "topic": "Addition", "difficulty": "Beginner"}
    }
]

def seed_knowledge():
    print("Seeding knowledge chunks...")
    for item in sample_knowledge:
        embedding = generate_embedding(item["content"])
        data = {
            "content": item["content"],
            "metadata": item["metadata"],
            "embedding": embedding
        }
        try:
            supabase.table("knowledge_chunks").insert(data).execute()
            print(f"Inserted: {item['content'][:30]}...")
        except Exception as e:
            print(f"Error inserting {item['content'][:30]}: {e}")
    print("Seeding complete.")

if __name__ == "__main__":
    seed_knowledge()
