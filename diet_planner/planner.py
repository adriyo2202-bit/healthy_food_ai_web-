import os
import urllib.request
import urllib.error
import json
import ssl

def generate_engaging_diet_plan(age: int, height: float, weight: float, goal: str) -> str:
    """
    Calls the Hugging Face Inference API to generate an engaging diet and fitness plan.
    """
    api_key = os.environ.get("HF_TOKEN")
    if not api_key:
        return "⚠️ **Error:** HF_TOKEN environment variable is not set. Please set it to use the AI features."
        
    try:
        url = "https://api.mistral.ai/v1/chat/completions"
        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {api_key}"
        }
        
        prompt = f"""
You are an energetic, fun, and highly engaging fitness and diet coach.
I am {age} years old, my height is {height} cm, and my weight is {weight} kg.
My fitness goal is: {goal}.

Please do the following in a highly animated, engaging, and readable way (use emojis, bold text, bullet points, and dynamic structure):
1. Calculate my BMI and explain what it means for me.
2. Based on my BMI and my goal ("{goal}"), tell me if I should aim for weight loss, weight gain, or weight maintenance.
3. Suggest an awesome, realistic daily diet plan (breakfast, lunch, dinner, snacks).
4. Suggest a list of highly beneficial foods I should definitely include.
5. Emphasize a list of foods I should absolutely AVOID to reach my goal.
6. Make the tone extremely engaging and real, like an enthusiastic YouTube fitness coach talking directly to me!
"""

        data = {
            "model": "mistral-small-latest",
            "messages": [
                {
                    "role": "user",
                    "content": prompt,
                }
            ],
            "temperature": 0.7
        }
        
        req = urllib.request.Request(url, headers=headers, data=json.dumps(data).encode('utf-8'))
        context = ssl._create_unverified_context()
        
        with urllib.request.urlopen(req, context=context, timeout=45) as response:
            res_data = json.loads(response.read().decode('utf-8'))
            return res_data['choices'][0]['message']['content']
            
    except urllib.error.HTTPError as e:
        return f"⚠️ **API Error:** HTTP {e.code} - {e.read().decode('utf-8')}"
    except Exception as e:
        return f"⚠️ **API Error:** {str(e)}"
