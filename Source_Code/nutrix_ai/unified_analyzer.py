import os
import sys
import json
import base64
import requests

# Ensure project root is in path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from project.ocr_new import ocr

# Fallback to demo key if env not set
MISTRAL_API_KEY = os.environ.get("MISTRAL_API_KEY", "IRje9hbMhqE5YdJZDxKNaG6AMQUmO17i")

def encode_image(image_path: str) -> str:
    with open(image_path, "rb") as image_file:
        return base64.b64encode(image_file.read()).decode('utf-8')

def run_label_analysis(image_path: str) -> dict:
    """
    1. Extracts raw OCR text via Docling
    2. Sends raw text + image to Mistral Pixtral-12b
    3. Prompts the vision model to output the complete Nutrix JSON structure
    """
    
    print(f"Running Base OCR on {image_path}...")
    try:
        raw_text = ocr(image_path, use_docling=True)
    except Exception as e:
        print(f"Base OCR failed, falling back to empty string: {e}")
        raw_text = ""
        
    print(f"Extracted Base Text: {raw_text[:150]}...")
    
    # Mistral unified prompt
    prompt = f"""You are 'Healthy Food AI', an expert nutrition and food safety analyst. 
Look at the attached image of a nutrition label or ingredients list, and use the following raw OCR text as a hint:
<raw_ocr>
{raw_text}
</raw_ocr>

Analyze the image carefully. Correct any OCR mistakes. Then, extract the ingredients and analyze them for health, safety, and EU standards. Also suggest healthy alternatives.

You MUST respond with a JSON object exactly matching this structure. The values for product_ingredients_raw and summary_bn_en MUST be flat strings, NOT nested objects. Do NOT include markdown tags, just the raw JSON:
{{
  "product_ingredients_raw": "A single string containing the corrected, full text of the ingredients list and/or nutrition facts.",
  "ingredients": [
    {{
      "name": "Ingredient Name",
      "name_bn": "Bengali translation of ingredient (or empty string)",
      "safety_verdict": "safe" | "caution" | "unsafe",
      "safety_reason": "Explanation of why it is safe/unsafe.",
      "eu_status": "permitted" | "banned" | "restricted",
      "eu_e_number": "E-number if applicable, else null",
      "eu_notes": "Any EU regulations or notes",
      "long_term_risk": true | false,
      "long_term_risk_detail": "Details of long-term risk, or empty string",
      "risk_severity": "none" | "low" | "moderate" | "high"
    }}
  ],
  "overall_safety_score": <integer from 0 to 100>,
  "warnings_detected": ["List of any allergens or warnings"],
  "allergen_flags": ["List of allergen names"],
  "summary_bn_en": "A single string containing a summary of the product's safety. Include a section for 'Healthy Alternatives' suggesting better options."
}}
"""

    base64_image = encode_image(image_path)
    url = "https://api.mistral.ai/v1/chat/completions"
    headers = {
        "Authorization": f"Bearer {MISTRAL_API_KEY}",
        "Content-Type": "application/json"
    }
    
    payload = {
        "model": "pixtral-12b-2409",
        "messages": [
            {
                "role": "user",
                "content": [
                    {"type": "text", "text": prompt},
                    {"type": "image_url", "image_url": f"data:image/jpeg;base64,{base64_image}"}
                ]
            }
        ],
        "response_format": {"type": "json_object"},
        "temperature": 0.1
    }
    
    print("Calling Mistral Vision API (Unified Analysis)...")
    try:
        response = requests.post(url, headers=headers, json=payload, timeout=90)
        response.raise_for_status()
        result_text = response.json()['choices'][0]['message']['content'].strip()
        
        if result_text.startswith("```json"):
            result_text = result_text.replace("```json", "", 1).strip()
        if result_text.endswith("```"):
            result_text = result_text[:-3].strip()
            
        parsed_json = json.loads(result_text)
        
        # Enforce string types for UI compatibility
        if isinstance(parsed_json.get("product_ingredients_raw"), dict):
            parsed_json["product_ingredients_raw"] = json.dumps(parsed_json["product_ingredients_raw"], indent=2)
        if isinstance(parsed_json.get("summary_bn_en"), dict):
            # Try to format it nicely if it separated by language
            summary = parsed_json["summary_bn_en"]
            if "en" in summary and "bn" in summary:
                parsed_json["summary_bn_en"] = f"{json.dumps(summary['en'], indent=2)}\n\n{json.dumps(summary['bn'], indent=2)}"
            else:
                parsed_json["summary_bn_en"] = json.dumps(summary, indent=2)
                
        print("Unified Analysis Complete!")
        return parsed_json
        
    except Exception as e:
        print(f"Error calling Mistral API: {e}")
        # Fallback to mock data if API fails
        return {
          "product_ingredients_raw": "API Request Failed",
          "ingredients": [
            {
              "name": "API Connection Error",
              "name_bn": "",
              "safety_verdict": "unknown",
              "safety_reason": f"Could not connect to Mistral API. Ensure your API key is valid and has credits. Error: {e}",
              "eu_status": "unknown",
              "eu_e_number": None,
              "eu_notes": "",
              "long_term_risk": False,
              "long_term_risk_detail": "",
              "risk_severity": "none"
            }
          ],
          "overall_safety_score": 0,
          "warnings_detected": ["API Error"],
          "allergen_flags": [],
          "summary_bn_en": "Please check your Mistral API key and try again."
        }
