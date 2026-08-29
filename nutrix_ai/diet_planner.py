import json
import urllib.request
import urllib.error
import ssl
import os

def generate_diet_plan(age: int, height: float, weight: float, goal: str, diet_type: str) -> dict:
    """
    Calls the Mistral AI API directly using standard libraries to generate an engaging diet and fitness plan.
    Returns a structured dictionary matching the JSON response.
    """
    api_key = os.environ.get("MISTRAL_API_KEY", "Qgpp1Kx0KoOlw1mxfRN0W1W8dip55gL1") # fallback if not in env
        
    prompt = f"""
You are a highly direct, bold, and precise fitness coach.
I am {age} years old, my height is {height} cm, and my weight is {weight} kg.
My fitness goal is: {goal}.
My diet preference is: {diet_type}.

You must return your response as a valid JSON object following this EXACT schema:
{{
  "bmi_verdict": "string (Briefly state BMI and give a STRONG verdict)",
  "goal_alignment": "string (Based on the goal, give a one-sentence direct mandate)",
  "daily_roadmap": {{
    "breakfast": "string",
    "lunch": "string",
    "dinner": "string",
    "snack": "string"
  }},
  "mandatory_fuel": ["list of 3-4 strings (essential foods)"],
  "strictly_forbidden": ["list of 3-4 strings (foods to AVOID completely)"]
}}

Keep the text values short, highly scannable, and extremely punchy. Do not include extra fluff.
"""

    url = "https://api.mistral.ai/v1/chat/completions"
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}"
    }
    data = {
        "model": "mistral-small-latest",
        "response_format": {"type": "json_object"},
        "messages": [
            {
                "role": "user",
                "content": prompt
            }
        ]
    }

    context = ssl._create_unverified_context()
    req = urllib.request.Request(url, data=json.dumps(data).encode("utf-8"), headers=headers, method="POST")
    try:
        with urllib.request.urlopen(req, context=context) as response:
            result = json.loads(response.read().decode("utf-8"))
            text = result["choices"][0]["message"]["content"]
            return json.loads(text)
    except urllib.error.HTTPError as e:
        return {"error": f"Mistral API Error: HTTP {e.code} - {e.read().decode('utf-8')}"}
    except Exception as e:
        return {"error": f"Mistral API Error: {str(e)}"}
