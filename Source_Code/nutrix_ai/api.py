from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from pydantic import BaseModel
import sys
import os
import json
from sqlalchemy.orm import Session

# Ensure the parent directory is in the path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from nutrix_ai.core.nutrix_intelligence import NutrixIntelligence
from nutrix_ai.cli_test import seed_test_data
from fastapi.middleware.cors import CORSMiddleware
from nutrix_ai.database import get_db, SessionLocal, User, UserPreference, HealthProfile, DietPlan, Conversation, Message, SavedItem
from nutrix_ai.auth import verify_password, get_password_hash, create_access_token, decode_access_token, ACCESS_TOKEN_EXPIRE_MINUTES
from datetime import timedelta

app = FastAPI(title="Nutrix AI API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

intelligence = NutrixIntelligence()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")

# Seeding
@app.on_event("startup")
def startup_event():
    print("Seeding test databases...")
    for db in ["nutrix_rag.db", "nutrix_rag_vectors.db", "nutrix_web.db", "nutrix_web_vectors.db"]:
        if os.path.exists(db):
            os.remove(db)
    global intelligence
    intelligence = NutrixIntelligence()
    seed_test_data(intelligence)
    
    # Seed developer bypass account
    db = SessionLocal()
    dev_email = "dev@cca.com"
    if not db.query(User).filter(User.email == dev_email).first():
        dev_user = User(email=dev_email, password_hash=get_password_hash("CCA_WELCOMES"))
        db.add(dev_user)
        db.commit()
        db.refresh(dev_user)
        db.add(UserPreference(user_id=dev_user.id))
        db.commit()
    db.close()
    
    print("Nutrix API is ready!")

# --- Auth Dependencies ---
def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    payload = decode_access_token(token)
    if payload is None:
        raise credentials_exception
    email: str = payload.get("sub")
    if email is None:
        raise credentials_exception
    user = db.query(User).filter(User.email == email).first()
    if user is None:
        raise credentials_exception
    return user

# --- Auth Endpoints ---
class UserCreate(BaseModel):
    email: str
    password: str

@app.post("/register")
def register(user: UserCreate, db: Session = Depends(get_db)):
    db_user = db.query(User).filter(User.email == user.email).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    hashed_password = get_password_hash(user.password)
    new_user = User(email=user.email, password_hash=hashed_password)
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    # Init empty preferences
    pref = UserPreference(user_id=new_user.id)
    db.add(pref)
    db.commit()
    
    return {"msg": "User created successfully"}

@app.post("/login")
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == form_data.username).first()
    if not user or not verify_password(form_data.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.email}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}

from google.oauth2 import id_token
from google.auth.transport import requests as google_requests

class GoogleAuthRequest(BaseModel):
    id_token: str

@app.post("/auth/google")
def google_auth(request: GoogleAuthRequest, db: Session = Depends(get_db)):
    try:
        # We will use the Google Client ID here. You can set it in environment variables
        GOOGLE_CLIENT_ID = os.environ.get("GOOGLE_CLIENT_ID", "YOUR_GOOGLE_CLIENT_ID_HERE.apps.googleusercontent.com")
        
        # Verify the token
        idinfo = id_token.verify_oauth2_token(
            request.id_token, 
            google_requests.Request(), 
            GOOGLE_CLIENT_ID
        )
        
        email = idinfo.get("email")
        if not email:
            raise HTTPException(status_code=400, detail="Google token does not contain an email")
            
        # Check if user exists
        user = db.query(User).filter(User.email == email).first()
        if not user:
            # Auto-register the Google user with a random unguessable password hash
            # since they authenticate via Google, not a local password.
            hashed_password = get_password_hash(os.urandom(24).hex())
            user = User(email=email, password_hash=hashed_password)
            db.add(user)
            db.commit()
            db.refresh(user)
            db.add(UserPreference(user_id=user.id))
            db.commit()
            
        # Issue our own JWT for the rest of the application
        access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
        access_token = create_access_token(
            data={"sub": user.email}, expires_delta=access_token_expires
        )
        return {"access_token": access_token, "token_type": "bearer"}
        
    except ValueError:
        raise HTTPException(status_code=401, detail="Invalid Google token")

class PreferencesUpdate(BaseModel):
    theme: str | None = None
    language: str | None = None
    ui_state: dict | None = None

@app.get("/user/preferences")
def get_preferences(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    pref = db.query(UserPreference).filter(UserPreference.user_id == current_user.id).first()
    return {
        "theme": pref.theme if pref else "light",
        "language": pref.language if pref else "en",
        "ui_state": json.loads(pref.ui_state) if pref and pref.ui_state else {}
    }

@app.post("/user/preferences")
def update_preferences(prefs: PreferencesUpdate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    pref = db.query(UserPreference).filter(UserPreference.user_id == current_user.id).first()
    if not pref:
        pref = UserPreference(user_id=current_user.id)
        db.add(pref)
    
    if prefs.theme is not None:
        pref.theme = prefs.theme
    if prefs.language is not None:
        pref.language = prefs.language
    if prefs.ui_state is not None:
        pref.ui_state = json.dumps(prefs.ui_state)
        
    db.commit()
    return {"msg": "Preferences updated"}

# --- Core App Endpoints ---
class ChatRequest(BaseModel):
    query: str

class ChatResponse(BaseModel):
    answer: str
    ui_indicators: list[str]
    sources: list[str]

@app.post("/chat", response_model=ChatResponse)
async def chat_endpoint(request: ChatRequest, current_user: User = Depends(get_current_user)):
    try:
        user_id_str = f"user_{current_user.id}"
        generator = intelligence.handle_query(request.query, user_id=user_id_str)
        
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
async def analyze_label_endpoint(file: UploadFile = File(...), current_user: User = Depends(get_current_user)):
    try:
        suffix = os.path.splitext(file.filename)[1] or ".jpg"
        with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
            shutil.copyfileobj(file.file, tmp)
            tmp_path = tmp.name
            
        print(f"File saved to {tmp_path} for analysis by User {current_user.id}")
        result_dict = run_label_analysis(tmp_path)
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
async def diet_plan_endpoint(request: DietPlanRequest, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
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
            
        # Save diet plan to database
        new_plan = DietPlan(user_id=current_user.id, plan_json=json.dumps(json_response))
        db.add(new_plan)
        db.commit()
        
        return json_response
    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)



from project.ocr_new import ocr

@app.post("/ocr-extract")
async def ocr_extract_endpoint(file: UploadFile = File(...), current_user: User = Depends(get_current_user)):
    try:
        import os
        import tempfile
        import shutil
        suffix = os.path.splitext(file.filename)[1] or ".jpg"
        with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
            shutil.copyfileobj(file.file, tmp)
            tmp_path = tmp.name
            
        print(f"Running OCR extraction on {tmp_path}")
        text = ocr(tmp_path)
        os.remove(tmp_path)
        return {"text": text}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
