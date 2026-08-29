import os
import sys

# Ensure project root is in path to import from project.ocr_new and project.ingre_demo_1
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from project.ocr_new import ocr
from project.ingre_demo_1 import NutriScanAnalyzer

MISTRAL_API_KEY = "IRje9hbMhqE5YdJZDxKNaG6AMQUmO17i"

def run_label_analysis(image_path: str) -> dict:
    """
    Runs OCR on the given image path, amplifies it via Pixtral (handled in ocr_new.py), and passes the refined text to the NutriScanAnalyzer.
    Returns the analysis result as a dictionary.
    """
    try:
        # Step 1: Run OCR on the image (which now internally amplifies using Mistral Pixtral-12b)
        print(f"Running OCR & Amplification on {image_path}...")
        refined_text = ocr(image_path, use_docling=True, amplify=True)
        print("OCR extracted text (REFINED):", refined_text[:200].replace('\n', ' '), "...")
        
        # Step 2: Pass refined text to the Mistral Analyzer
        print("Analyzing ingredients with Mistral...")
        os.environ["MISTRAL_API_KEY"] = MISTRAL_API_KEY
        analyzer = NutriScanAnalyzer()
        result = analyzer.analyze_from_ocr_text(refined_text)
        
        # Return structured dict
        from dataclasses import asdict
        return asdict(result)
        
    except Exception as e:
        print(f"Error during analysis: {e}")
        raise e
