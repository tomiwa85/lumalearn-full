# LumaLearn 🧠

**Guided Learning Application powered by AI & Socratic Method.**

LumaLearn is a Flutter-based mobile application designed to teach students by **guiding** them through problems rather than giving direct answers. It uses a "Hint-First" architecture to encourage critical thinking.

![LumaLearn Banner](assets/icons/icon_lumalearn.png)

## ✨ Features

- **Auth System:** Secure Email/Password login with Supabase.
- **Socratic AI Tutor:** Interactive chat session with progressive hints (Locked/Unlocked states).
- **RAG-Ready UI:** Topic breakdowns and grounded responses.
- **Dark & Neon UI:** A modern, focus-driven aesthetic designed for students.
- **Visual Analytics:** Heatmaps and mastery tracking to visualize growth.

## 🛠 Tech Stack

- **Framework:** Flutter (Dart)
- **State Management:** Riverpod (ConsumerWidget & Providers)
- **Navigation:** GoRouter (Declarative routing with Guards)
- **Backend:** Supabase (Auth & Database)
- **Rendering:** Flutter Markdown & LaTeX support

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.2.0 or higher)
- A Supabase Project (Free Tier)

### Installation

1. **Clone the repo**
   ```bash
   git clone [https://github.com/tomiwa85/lumalearn.git](https://github.com/tomiwa85/lumalearn.git)
   cd lumalearn