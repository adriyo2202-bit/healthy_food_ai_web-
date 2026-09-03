<div align="center">
  <img src="self_study_dl/assets/logo.png" alt="Healthy Food AI Logo" width="150"/>
  <h1>🥗 Healthy Food AI</h1>
  <p><strong>Personal Health Intelligence Powered by RAG & Generative AI</strong></p>

  <p>
    <img src="https://img.shields.io/badge/Frontend-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
    <img src="https://img.shields.io/badge/Backend-FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white" alt="FastAPI" />
    <img src="https://img.shields.io/badge/AI-Mistral-FF7000?style=for-the-badge&logo=mistral&logoColor=white" alt="Mistral AI" />
    <img src="https://img.shields.io/badge/Database-SQLite%20%7C%20ChromaDB-003B57?style=for-the-badge&logo=sqlite&logoColor=white" alt="Database" />
  </p>
</div>

---

## 📖 Overview

**Healthy Food AI** is an intelligent, full-stack health application designed to provide personalized diet planning, ingredient analysis, and nutritional guidance. It uses **Retrieval-Augmented Generation (RAG)** to query scientific food datasets (like the Indian Food Composition Tables) and feeds that context into a Large Language Model (Mistral API) to provide highly accurate, roadmap-style dietary advice.

The frontend is built using **Flutter Web**, featuring a custom mathematical tracing animation (`CustomPaint`) and a highly responsive, glassmorphism-inspired UI.

---

## ✨ Core Features

*   **🤖 AI Diet Planner**: Generates fully customized, goal-oriented diet and fitness roadmaps using RAG and Mistral LLM.
*   **🔎 Ingredient Scanner**: Analyzes complex food ingredients and flags safety concerns based on official health guidelines (e.g., FSSAI).
*   **🎨 Premium Animated UI**: Features a buttery-smooth 60 FPS mathematical tracing animation on the splash screen (zero heavy video/GIF assets required).
*   **💻 Interactive Dashboard**: A simulated web environment with parallax scrolling, floating orbs, and an integrated AI chat workspace.

---

## 🏗️ Architecture & Tech Stack

### Frontend (User Interface)
*   **Framework:** Flutter (Compiled to Web)
*   **Language:** Dart
*   **Key Features:** Custom Vector Graphics, Glassmorphism aesthetics, `GoogleFonts.inter` typography.

### Backend (AI & API)
*   **Framework:** FastAPI
*   **Language:** Python 3
*   **AI Engine:** Mistral API
*   **Vector Database (RAG):** ChromaDB for semantic search over high-dimensional text embeddings.
*   **Relational Database:** SQLite with Full-Text Search (FTS) for lightning-fast exact keyword matching over food datasets (`ifct.db`, `nutrix_rag.db`).

---

## 🚀 Getting Started

Follow these steps to run the project locally on your machine.

### 1. Prerequisites
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (If you wish to modify the frontend UI)
*   Python 3.9+ 
*   A Mistral API Key (Stored in your environment variables)

### 2. Running the Backend
The Python FastAPI server processes all AI queries.
```bash
# Navigate to the project root
cd new_feature_project

# Activate the virtual environment
source project/venv/bin/activate

# Start the FastAPI Server (Runs on port 8000)
python3 -m uvicorn nutrix_ai.api:app --host 0.0.0.0 --port 8000
```

### 3. Running the Frontend
The Flutter frontend is already compiled into highly optimized static web files. You don't need the Flutter SDK just to run it!
```bash
# Open a new terminal and navigate to the web build folder
cd self_study_dl/build/web

# Start a simple Python HTTP server (Runs on port 3000)
python3 -m http.server 3000
```

**View the App:** Open your browser and navigate to `http://localhost:3000`

---

## 🧠 How the AI RAG Pipeline Works

1. **User Prompt:** The user types *"I want a high protein diet for weight loss"* in the Flutter UI.
2. **Retrieval:** The FastAPI backend receives the request and queries both ChromaDB (Semantic Search) and SQLite FTS (Keyword Search) to pull scientifically accurate food data.
3. **Augmentation:** This raw data is injected into a strict system prompt as context.
4. **Generation:** The Mistral API processes the enriched prompt and generates a natural, personalized response.
5. **Streaming Delivery:** The response is instantly delivered back to the Flutter UI for the user to read.

---
<div align="center">
  <i>Built with ❤️ for a healthier future.</i>
</div>
