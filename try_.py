import os
import urllib.request
import urllib.error
import json
import sys
import ssl

def get_mistral_response(messages, api_key):
    url = "https://api.mistral.ai/v1/chat/completions"
    headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": f"Bearer {api_key}"
    }
    
    # We use open-mistral-7b as it might be more accessible for new free-tier accounts
    data = {
        "model": "mistral-small-latest",
        "messages": messages,
        "temperature": 0.7,
        "stream": True
    }
    
    req = urllib.request.Request(url, headers=headers, data=json.dumps(data).encode('utf-8'))
    
    try:
        # Create an unverified SSL context to fix the CERTIFICATE_VERIFY_FAILED error on macOS
        context = ssl._create_unverified_context()
        with urllib.request.urlopen(req, context=context, timeout=30) as response:
            for line in response:
                line = line.decode('utf-8').strip()
                if line.startswith("data: "):
                    data_str = line[6:]
                    if data_str == "[DONE]":
                        break
                    try:
                        chunk = json.loads(data_str)
                        delta = chunk['choices'][0]['delta']
                        if 'content' in delta:
                            yield delta['content']
                    except json.JSONDecodeError:
                        continue
    except urllib.error.HTTPError as e:
        print(f"\n[Error connecting to Mistral API]: HTTP {e.code} {e.reason}")
        try:
            error_details = e.read().decode('utf-8')
            print(f"Details from Mistral: {error_details}")
            if e.code == 401:
                print("\nHint: A 401 error on a brand new key usually means Mistral requires you to attach a payment method to your account to activate the API key, even for free tiers.")
        except:
            pass
        yield None
    except urllib.error.URLError as e:
        print(f"\n[Error connecting to Mistral API]: {e.reason}")
        yield None
    except Exception as e:
        print(f"\n[Unexpected Error]: {e}")
        yield None

def main():
    print("Welcome to your Personal AI Assistant!")
    print("You can chat about your diet, ask for general information, or just have a normal conversation.")
    print("Type 'exit' or 'quit' to end the chat.\n")
    
    # Using the provided API key
    api_key = "SfruVWOyGjv45cMX5sbWLB2XbFUgEDlj"

    system_prompt = """You are a helpful, realistic, and natural-sounding AI assistant. 
You are highly knowledgeable about diets, nutrition, and general information.
When users discuss their diet, provide practical, personalized, and constructive feedback. Listen to their modifications and preferences carefully.
Keep your tone conversational, empathetic, and human-like.
CRITICAL RULE: You must strictly avoid any graphic, violent, or 'gore' language under all circumstances. Keep all discussions safe, respectful, and helpful.
"""

    # Initialize chat history with the system prompt
    messages = [
        {"role": "system", "content": system_prompt}
    ]

    print("\nAssistant: Hello! I'm here to help you with your diet plan, answer any questions you have, or just chat. How can I help you today?")
    
    while True:
        try:
            user_input = input("\nYou: ").strip()
            
            if user_input.lower() in ['exit', 'quit']:
                print("\nAssistant: Goodbye! Have a great day and stay healthy!")
                break
                
            if not user_input:
                continue
                
            # Add user message to history
            messages.append({"role": "user", "content": user_input})
            
            # Fetch response
            print("Assistant: ", end="", flush=True)
            generator = get_mistral_response(messages, api_key)
            
            reply = ""
            for chunk in generator:
                if chunk is None:
                    # Error occurred
                    reply = None
                    break
                print(chunk, end="", flush=True)
                reply += chunk
                
            print() # Print a newline after the response completes
            
            if reply:
                # Add assistant response to history
                messages.append({"role": "assistant", "content": reply})
            else:
                # Remove the last user message if the API call failed so they can try again
                messages.pop()
                
        except KeyboardInterrupt:
            print("\n\nAssistant: Goodbye! Have a great day!")
            break
        except Exception as e:
            print(f"\nAn error occurred: {e}")

if __name__ == "__main__":
    main()
