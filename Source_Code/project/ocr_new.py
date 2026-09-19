import cv2
import numpy as np
import pytesseract
import logging
from pathlib import Path
from ultralytics import YOLO

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("ocr_yolo_pipeline")

# Try to load the CoreML INT8 model if available, fallback to PyTorch
MODEL_PATH = Path(__file__).parent / "yolov8n.mlpackage"
if not MODEL_PATH.exists():
    MODEL_PATH = Path(__file__).parent / "yolov8n.pt"

try:
    logger.info(f"Loading YOLO model from {MODEL_PATH}")
    yolo_model = YOLO(str(MODEL_PATH))
except Exception as e:
    logger.error(f"Failed to load YOLO model: {e}")
    yolo_model = None

def ocr(image_path: str, **kwargs) -> str:
    """
    1. Detects text/object bounding boxes using YOLOv8.
    2. Crops the image exactly to the bounding boxes.
    3. Runs PyTesseract OCR purely on the clean crops.
    """
    if not yolo_model:
        return "OCR Initialization Failed: YOLO model not found."

    logger.info(f"Running YOLOv8 Text Detection on {image_path}")
    image = cv2.imread(image_path)
    if image is None:
        return "Error: Image not found or unreadable."

    # 1. YOLO Detection
    results = yolo_model.predict(image, conf=0.25, verbose=False)
    
    extracted_texts = []
    
    for r in results:
        boxes = r.boxes
        
        # Sort boxes top-to-bottom
        sorted_indices = sorted(range(len(boxes.xyxy)), key=lambda k: boxes.xyxy[k][1])
        
        for i in sorted_indices:
            box = boxes.xyxy[i]
            x1, y1, x2, y2 = map(int, box[:4])
            
            # 2. Crop Image
            # Add a small margin to improve Tesseract reading
            margin = 5
            h, w = image.shape[:2]
            crop_y1 = max(0, y1 - margin)
            crop_y2 = min(h, y2 + margin)
            crop_x1 = max(0, x1 - margin)
            crop_x2 = min(w, x2 + margin)
            
            cropped = image[crop_y1:crop_y2, crop_x1:crop_x2]
            
            # Preprocess crop (grayscale & threshold) for Tesseract
            gray = cv2.cvtColor(cropped, cv2.COLOR_BGR2GRAY)
            thresh = cv2.adaptiveThreshold(gray, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY, 11, 2)
            
            # 3. Tesseract Extraction
            text = pytesseract.image_to_string(thresh).strip()
            if text:
                extracted_texts.append(text)

    # 4. Reconstruct Text
    # If YOLO didn't find specific boxes, fallback to full image Tesseract
    if not extracted_texts:
        logger.warning("YOLO found no boxes, falling back to full-page Tesseract.")
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        text = pytesseract.image_to_string(gray).strip()
        return text

    final_text = "\n".join(extracted_texts)
    return final_text

if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1:
        print(ocr(sys.argv[1]))
