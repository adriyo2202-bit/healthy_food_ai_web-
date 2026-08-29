from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import sys
import os

# Ensure the parent directory is in the path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from nutrix_ai.core.nutrix_intelligence import NutrixIntelligence
from nutrix_ai.cli_test import seed_test_data

from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Nutrix AI API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize the intelligence layer globally
intelligence = NutrixIntelligence()

# Seed data on startup (for testing)
@app.on_event("startup")
def startup_event():
    print("Seeding test databases...")
    for db in ["nutrix_rag.db", "nutrix_rag_vectors.db", "nutrix_web.db", "nutrix_web_vectors.db"]:
        if os.path.exists(db):
            os.remove(db)
    # Re-init to recreate fresh tables
    global intelligence
    intelligence = NutrixIntelligence()
    seed_test_data(intelligence)
    print("Nutrix API is ready!")

class ChatRequest(BaseModel):
    query: str
    user_id: str = "user_A"

class ChatResponse(BaseModel):
    answer: str
    ui_indicators: list[str]
    sources: list[str]

@app.post("/chat", response_model=ChatResponse)
async def chat_endpoint(request: ChatRequest):
    try:
        # Run the generator
        generator = intelligence.handle_query(request.query, user_id=request.user_id)
        
        full_text = ""
        ui_indicators = []
        sources = []
        
        for chunk in generator:
            if chunk.startswith("[UI:"):
                ui_indicators.append(chunk.strip())
            elif chunk.startswith("Sources:\n") or chunk.startswith("\n\nSources:\n"):
                sources.append(chunk.strip())
            else:
                full_text += chunk
                
        return ChatResponse(
            answer=full_text.strip(),
            ui_indicators=ui_indicators,
            sources=sources
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

from fastapi import UploadFile, File
import shutil
import tempfile
from nutrix_ai.unified_analyzer import run_label_analysis

@app.post("/analyze-label")
async def analyze_label_endpoint(file: UploadFile = File(...)):
    try:
        # Create a temp file to save the uploaded image
        suffix = os.path.splitext(file.filename)[1] or ".jpg"
        with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
            shutil.copyfileobj(file.file, tmp)
            tmp_path = tmp.name
            
        print(f"File saved to {tmp_path} for analysis")
        
        # Run analysis
        result_dict = run_label_analysis(tmp_path)
        
        # Clean up temp file
        os.remove(tmp_path)
        
        return result_dict
    except Exception as e:
        print(f"Analysis Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

class DietPlanRequest(BaseModel):
    age: int
    height: float
    weight: float
    goal: str
    diet_type: str

from nutrix_ai.diet_planner import generate_diet_plan

@app.post("/diet-plan")
async def diet_plan_endpoint(request: DietPlanRequest):
    try:
        json_response = generate_diet_plan(
            age=request.age,
            height=request.height,
            weight=request.weight,
            goal=request.goal,
            diet_type=request.diet_type
        )
        if "error" in json_response:
            raise HTTPException(status_code=500, detail=json_response["error"])
        return json_response
    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)
