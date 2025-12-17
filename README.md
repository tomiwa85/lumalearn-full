<div align="center">
  <img src="assets/icon_lumalearn.png" alt="LumaLearn Logo" width="120" height="120">
  
  # LumaLearn
  
  **AI-Powered Socratic Tutoring Platform**

  [![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
  [![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
  [![FastAPI](https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com/)
  [![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com/)
  [![Llama 3](https://img.shields.io/badge/AI-Llama%203-blueviolet?style=for-the-badge)](https://groq.com/)

  <p align="center">
    LumaLearn replaces rote memorization with deep understanding using valid Socratic questioning.
  </p>
</div>

---

## 🚀 Overview

LumaLearn is an advanced educational platform that uses Large Language Models (LLMs) to function as a personalized tutor. Unlike standard chatbots that give direct answers, LumaLearn acts like a real teacher—guiding students to the solution through step-by-step questioning (the Socratic Method).

## 🧠 Methodology

### The Socratic Tutor Engine
The core of LumaLearn is its **Tutor Engine**, which strictly adheres to pedagogical principles:
- **Diagnosis**: Assesses user knowledge before explaining.
- **Scaffolding**: Breaks complex problems into smaller, manageable steps.
- **Guiding Questions**: Encourages critical thinking rather than passive consumption.
- **Guardrails**: Prevents the AI from doing homework for the student.

### Retrieval-Augmented Generation (RAG)
To ensure accuracy, LumaLearn employs a RAG system:
- **Vector Database**: Knowledge chunks are stored with vector embeddings (pgvector).
- **Context Injection**: Relevant textbooks and notes are retrieved and injected into the AI's context window.
- **Grounded Answers**: The AI responds using specific, verified curriculum data.

---

## 🏗️ Technical Architecture

### 📱 Frontend (Flutter)
- **Framework**: Cross-platform mobile/desktop app using Flutter.
- **State Management**: **Riverpod** for reactive, testable state management.
- **Navigation**: **GoRouter** for declarative routing.
- **Authentication**: Native Supabase Auth handling email/password and sessions.
- **Design System**: Custom modern UI theme with neon accents and dark mode.

### ⚙️ Backend (Python FastAPI)
- **API**: High-performance asynchronous REST API built with **FastAPI**.
- **Services**:
  - `tutor_engine.py`: Orchestrates the prompting logic and response handling.
  - `groq_service.py`: Interface for the high-speed Groq API (Llama 3-8b).
  - `rag_service.py`: Handles vector similarity search.
- **Database**: **Supabase (PostgreSQL)** serves as both the relational DB (users, sessions) and the vector store (embeddings).

---

## 🛠️ Installation & Setup

### Prerequisites
- Flutter SDK (v3.0+)
- Python (v3.9+)
- Supabase Project
- Groq API Key

### 1. Backend Setup
```bash
cd ai_tutor_backend
python -m venv .venv
# Activate Virtual Env (Windows: .venv\Scripts\activate, Mac/Linux: source .venv/bin/activate)
pip install -r requirements.txt
```

Create a `.env` file in `ai_tutor_backend`:
```env
GROQ_API_KEY=your_key_here
SUPABASE_URL=your_supabase_url
SUPABASE_KEY=your_supabase_anon_key
```

### 2. Run the Server
```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### 3. Frontend Setup
Update the server URL in `lib/features/session/services/ai_service.dart` if testing on a physical device (use your local IP).

```bash
cd lumalearn
flutter pub get
flutter run
```

---

## 🛡️ Scout Mode (Parental Oversight)
LumaLearn includes a dedicated mode for parents/guardians:
- **Activity Monitoring**: View interaction history.
- **Progress Reports**: AI-generated summaries of student strengths and weaknesses.
- **Safety**: Ensuring the AI remains helpful and appropriate.

---

<div align="center">
  Built by Olatomiwa Ojo
</div>
