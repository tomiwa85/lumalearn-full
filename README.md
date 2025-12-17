# LumaLearn

LumaLearn is an AI-powered personalized tutoring application designed to help students learn through the Socratic method. It features a Flutter cross-platform frontend and a Python FastAPI backend powered by Groq (Llama 3).

## Features
- **Personalized Tutoring**: AI adapts to the student's level and subject.
- **Socratic Method**: Guiding questions instead of direct answers.
- **Subject-Specific Chats**: History tracking for distinct subjects (Math, Science, etc.).
- **Scout Mode**: Parent monitoring (simulated).
- **RAG System**: Retrieval-Augmented Generation for context-aware answers.

## Architecture
- **Frontend**: Flutter (Riverpod for state management, Supabase for auth/db).
- **Backend**: Python FastAPI.
- **AI/LLM**: Groq API (Llama 3-8b).
- **Database**: Supabase (PostgreSQL + pgvector).

## Getting Started

### Prerequisites
- Flutter SDK
- Python 3.9+
- Supabase Account
- Groq API Key

### Setup

1. **Clone the repository**
2. **Backend Setup**
   ```bash
   cd ai_tutor_backend
   python -m venv .venv
   .venv\Scripts\activate  # Windows
   pip install -r requirements.txt
   ```
3. **Environment Variables**
   Create a `.env` file in `ai_tutor_backend`:
   ```env
   GROQ_API_KEY=your_key
   SUPABASE_URL=your_url
   SUPABASE_KEY=your_key
   ```

### Running the App

1. **Start the Backend Server**
   ```bash
   cd ai_tutor_backend
   # Make sure venv is activated
   uvicorn main:app --host 0.0.0.0 --port 8000 --reload
   ```

2. **Start the Frontend**
   ```bash
   cd lumalearn
   flutter run
   ```

## Development
- **API URL**: In `lib/features/session/services/ai_service.dart`, set `_serverUrl` to `http://127.0.0.1:8000/chat` for local Windows dev, or your machine's IP for mobile testing.
