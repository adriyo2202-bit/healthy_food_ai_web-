import os
import sys
import json
import urllib.request
import urllib.error
import ssl
import re

try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass

# Colors for terminal output
GREEN = "\033[92m"
YELLOW = "\033[93m"
CYAN = "\033[96m"
WHITE = "\033[97m"
BOLD = "\033[1m"
RESET = "\033[0m"

def print_header(title: str):
    print(f"\n{BOLD}{CYAN}{'='*60}{RESET}")
    print(f"{BOLD}{GREEN}  {title.upper()}{RESET}")
    print(f"{BOLD}{CYAN}{'='*60}{RESET}\n")

def get_validated_input(prompt, cast_type, error_msg):
    while True:
        try:
            val = input(f"{BOLD}{WHITE}{prompt}{RESET} ").strip()
            return cast_type(val)
        except ValueError:
            print(f"{YELLOW}Invalid input. {error_msg}{RESET}")
        except KeyboardInterrupt:
            print(f"\n{YELLOW}Exiting...{RESET}")
            sys.exit(0)

def generate_engaging_diet_plan(age: int, height: float, weight: float, goal: str, diet_type: str) -> str:
    """
    Calls the Mistral AI API directly using standard libraries to generate an engaging diet and fitness plan.
    No external 'mistralai' package required!
    """
    api_key = "Qgpp1Kx0KoOlw1mxfRN0W1W8dip55gL1"
        
    prompt = f"""
You are a highly direct, bold, and precise fitness coach.
I am {age} years old, my height is {height} cm, and my weight is {weight} kg.
My fitness goal is: {goal}.
My diet preference is: {diet_type}.

Provide a highly concise, roadmap-style action plan. Use strong verdicts, minimal text, and make critical points **BOLD**. 
To add colors, you MUST wrap text in these exact tags: <red>text</red>, <green>text</green>, <cyan>text</cyan>, <yellow>text</yellow>. Use colors liberally for emphasis!

Follow this exact roadmap structure:
1. 🏁 **[BMI VERDICT]**: Briefly state BMI and give a STRONG verdict. Use <red> or <green> based on health.
2. 🎯 **[GOAL ALIGNMENT]**: Based on "{goal}", give a one-sentence direct mandate.
3. 🗺️ **[DAILY ROADMAP]**: Concise meal roadmap (Breakfast, Lunch, Dinner, Snack). Bullet points, extremely short descriptions.
4. ✅ **[MANDATORY FUEL]**: 3-4 essential foods.
5. 🚫 **[STRICTLY FORBIDDEN]**: 3-4 foods to AVOID. Use <red> and **bold** for these.

Keep the overall output short, highly scannable, and extremely punchy. Do not include extra fluff.
"""

    url = "https://api.mistral.ai/v1/chat/completions"
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}"
    }
    data = {
        "model": "mistral-small-latest",
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
            
            # Parse color tags into terminal ANSI codes
            text = text.replace("<red>", "\033[91m").replace("</red>", "\033[0m")
            text = text.replace("<green>", "\033[92m").replace("</green>", "\033[0m")
            text = text.replace("<cyan>", "\033[96m").replace("</cyan>", "\033[0m")
            text = text.replace("<yellow>", "\033[93m").replace("</yellow>", "\033[0m")
            
            # Parse markdown bold (**text**) into terminal bold
            text = re.sub(r'\*\*(.*?)\*\*', r'\033[1m\1\033[0m', text)
            
            return text
    except urllib.error.HTTPError as e:
        return f"⚠️ **Mistral API Error:** HTTP {e.code} - {e.read().decode('utf-8')}"
    except Exception as e:
        return f"⚠️ **Mistral API Error:** {str(e)}"

def main():
    print_header("Engaging AI Diet Planner (Mistral Powered)")
    
    age = get_validated_input("Enter your age:", int, "Please enter a valid whole number for age.")
    height = get_validated_input("Enter your height in cm:", float, "Please enter a valid number for height.")
    weight = get_validated_input("Enter your weight in kg:", float, "Please enter a valid number for weight.")
    
    print(f"\n{BOLD}{WHITE}What is your primary goal?{RESET}")
    print("1. Body building")
    print("2. Just be fit")
    
    goal_str = "Just be fit"
    while True:
        try:
            goal_choice = input(f"{BOLD}{WHITE}Choose 1 or 2: {RESET}").strip()
            if goal_choice == '1':
                goal_str = "Body building"
                break
            elif goal_choice == '2':
                goal_str = "Just be fit"
                break
            else:
                print(f"{YELLOW}Invalid choice. Enter 1 or 2.{RESET}")
        except KeyboardInterrupt:
            print(f"\n{YELLOW}Exiting...{RESET}")
            sys.exit(0)

    print(f"\n{BOLD}{WHITE}Are you Veg or Non-Veg?{RESET}")
    print("1. Veg")
    print("2. Non-Veg")
    
    diet_str = "Veg"
    while True:
        try:
            diet_choice = input(f"{BOLD}{WHITE}Choose 1 or 2: {RESET}").strip()
            if diet_choice == '1':
                diet_str = "Veg"
                break
            elif diet_choice == '2':
                diet_str = "Non-Veg"
                break
            else:
                print(f"{YELLOW}Invalid choice. Enter 1 or 2.{RESET}")
        except KeyboardInterrupt:
            print(f"\n{YELLOW}Exiting...{RESET}")
            sys.exit(0)

    print(f"\n{CYAN}🤖 Sending your details to the AI Coach... Please wait!{RESET}\n")
    
    # Call the Mistral API
    result = generate_engaging_diet_plan(age, height, weight, goal_str, diet_str)
    
    print_header("Your Personalized AI Coach Output")
    print(result)
    print(f"\n{BOLD}{GREEN}Stay healthy! Goodbye.{RESET}\n")

if __name__ == "__main__":
    main()
