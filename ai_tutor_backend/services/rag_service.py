
from services.groq_service import client
from core.database import supabase
import json

# Try to import sentence_transformers, but fail gracefully if not installed (for lightweight envs)
try:
    from sentence_transformers import SentenceTransformer
    # Load a small efficient model
    embedding_model = SentenceTransformer('all-MiniLM-L6-v2')
except ImportError:
    embedding_model = None
    print("Warning: sentence-transformers not found. RAG will be limited.")

def generate_embedding(text: str) -> list:
    if embedding_model:
        return embedding_model.encode(text).tolist()
    else:
        # Fallback or raise error. For now, return a zero vector or mock.
        # This is CRITICAL: If no model, we can't do vector search 
        # unless we use an API like OpenAI or Groq (if they offer embeddings).
        # Groq doesn't offer embeddings yet natively in the standard client in some versions.
        # We will assume the user installs the requirements.txt.
        return [0.0] * 384

def retrieve_context(query: str, match_threshold: float = 0.5, match_count: int = 3) -> str:
    """
    Retrieves relevant knowledge chunks from Supabase.
    """
    if not embedding_model:
        return "RAG Context: (Embedding model not loaded, cannot retrieve)"

    query_embedding = generate_embedding(query)
    
    try:
        response = supabase.rpc(
            "match_documents",
            {
                "query_embedding": query_embedding,
                "match_threshold": match_threshold,
                "match_count": match_count
            }
        ).execute()
        
        # Parse response
        matches = response.data
        if not matches:
            return ""
            
        context_str = "\n".join([f"- {match['content']}" for match in matches])
        return context_str
        
    except Exception as e:
        print(f"Error retrieving context: {e}")
        return ""
