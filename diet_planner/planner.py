import os
from mistralai.client import Mistral

def generate_engaging_diet_plan(age: int, height: float, weight: float, goal: str) -> str:
    """
    Calls the Mistral AI API to generate an engaging diet and fitness plan.
    """
    api_key = os.environ.get("MISTRAL_API_KEY")
    if not api_key:
        return "⚠️ **Error:** MISTRAL_API_KEY environment variable is not set. Please set it to use the AI features."
        
    try:
        client = Mistral(api_key=api_key)
        
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

        # Using mistral-large-latest for the best conversational ability and following complex instructions
        chat_response = client.chat.complete(
            model="mistral-large-latest",
            messages=[
                {
                    "role": "user",
                    "content": prompt,
                },
            ]
        )
        
        return chat_response.choices[0].message.content
        
    except Exception as e:
        return f"⚠️ **Mistral API Error:** {str(e)}"
