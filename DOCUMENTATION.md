# Healthy Food AI - Complete Project Documentation

Healthy Food AI is an intelligent, full-stack application designed to provide personalized health intelligence, dietary planning, and ingredient analysis. It leverages a modern frontend architecture built with Flutter, powered by a sophisticated AI backend utilizing Retrieval-Augmented Generation (RAG) and the Mistral API.

---

## 1. Architecture & Tech Stack

### Frontend (UI / UX)
- **Framework:** Flutter (compiled to Web via `flutter build web`).
- **Language:** Dart.
- **Design System:** Custom Glassmorphism aesthetic, dynamically rendered SVG/Vector animations (`CustomPaint`), and fully responsive layouts (Mobile, Tablet, Desktop).
- **Core Files:** Located in the `self_study_dl/lib/` directory (e.g., `splash_screen.dart`, `prototype_web_sim.dart`, `diet_planner_screen.dart`).

### Backend (API & AI)
- **Framework:** FastAPI (Python).
- **Language:** Python 3.
- **AI Model:** Mistral API for Large Language Model (LLM) completions.
- **Search & Retrieval (RAG):**
  - **ChromaDB:** For high-dimensional vector embeddings and semantic search.
  - **SQLite (FTS):** Full-Text Search for extremely fast keyword matching over food databases (`nutrix_rag.db`, `nutrix_web.db`, `ifct.db`).
- **Core Files:** Located in the `nutrix_ai/` directory and `run_demo.py`.

---

## 2. Core Features

### 🎨 The "Wow Factor" Splash Screen
- A highly optimized, custom mathematical tracing animation (`CustomPaint`).
- Simulates an invisible pen drawing a fork and leaf using bezier curves (`easeInOutSine`), avoiding the need for heavy GIF or video assets to ensure instant load times at 60 FPS.

### 📱 Simulated Web Dashboard
- A beautiful, layered, scroll-driven UI containing animated floating orbs and parallax effects.
- An interactive **AI Workspace Search Bar** that sends prompts directly to the FastAPI backend and streams the AI's intelligent responses back in real-time.

### 🥗 AI Diet Planner
- Generates highly customized, roadmap-style diet and fitness plans.
- Adapts to user goals (e.g., High Protein, Weight Loss) by retrieving scientifically accurate food data using RAG.

### 🔍 Ingredient Scanner & Health Lens
- Allows users to analyze complex food ingredients, check safety guidelines, and understand nutritional breakdowns (integrated with FSSAI guidelines).

---

## 3. How the AI Pipeline Works

When a user types a prompt (e.g., *"What should I eat tonight? My goal is high protein"*):

1. **Frontend Request:** The Flutter app's `sendChatMessage` function packages the prompt into JSON and sends an HTTP POST request to the backend (`http://127.0.0.1:8000/chat`).
2. **Backend Processing:**
   - **RAG Retrieval:** The `NutrixIntelligence` layer queries ChromaDB and the SQLite FTS databases to find scientifically accurate context (e.g., high-protein Indian foods from the IFCT dataset).
   - **Context Injection:** The retrieved data is injected into a strict system prompt.
3. **LLM Generation:** The enriched prompt is sent to the Mistral API, which generates a natural language, personalized response.
4. **Streaming Response:** The FastAPI server returns the AI's answer back to the Flutter UI, which renders it beautifully in the chat interface.

---

## 4. Setup and Execution Guide

### Prerequisites
- Flutter SDK (for modifying the frontend).
- Python 3.9+ (for the backend).
- Mistral API Key (set in environment variables for backend processing).

### Running the Backend (Python)
Navigate to the root directory and activate your virtual environment, then start the FastAPI server:
```bash
python3 -m uvicorn nutrix_ai.api:app --host 0.0.0.0 --port 8000
```
*Note: The backend must be running on port 8000 for the frontend to successfully connect.*

### Running the Frontend (Flutter Web)
Since the app is already compiled into static web files, you do not need the Flutter development server to view it. Simply serve the `build/web` directory:
```bash
cd self_study_dl/build/web
python3 -m http.server 3000
```
Open your browser and navigate to `http://localhost:3000` to view the app!

---

## 5. Security & Deployment

- **Current State:** The application is configured for secure local demonstration (`127.0.0.1`). 
- **Database Safety:** The RAG databases (`*.db`) and ChromaDB vector stores are kept lightweight and local.
- **Git Repository:** Heavy dependencies (like the 2.4 GB Flutter SDK `app_dev/` folder) are strictly ignored via `.gitignore` to keep the GitHub repository clean and fast to clone. The project is successfully synced to your remote GitHub (`healthy_food_ai_web-`).
