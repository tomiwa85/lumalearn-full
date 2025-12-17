
from supabase import create_client, Client
from .config import settings

url: str = settings.SUPABASE_URL
# Prefer the Service Role Key for backend operations to bypass RLS
key: str = settings.SUPABASE_SERVICE_ROLE_KEY if settings.SUPABASE_SERVICE_ROLE_KEY else settings.SUPABASE_KEY

supabase: Client = create_client(url, key)
