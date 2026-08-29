import json
import urllib.request
import urllib.error
import ssl
import logging

logger = logging.getLogger(__name__)

MISTRAL_API_KEY = "SfruVWOyGjv45cMX5sbWLB2XbFUgEDlj"

class LLMProvider:
    """
    Abstractions for the Fine-Tuned (or base) LLM. 
    Here we use open-mistral-7b as the stand-in for the fine-tuned model.
    """
    def __init__(self, api_key=MISTRAL_API_KEY):
        self.api_key = api_key

    def generate_stream(self, messages):
        url = "https://api.mistral.ai/v1/chat/completions"
        headers = {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": f"Bearer {self.api_key}"
        }
        
        data = {
            "model": "mistral-small-latest", 
            "messages": messages,
            "temperature": 0.5,
            "stream": True
        }
        
        req = urllib.request.Request(url, headers=headers, data=json.dumps(data).encode('utf-8'))
        
        try:
            context = ssl._create_unverified_context()
            with urllib.request.urlopen(req, context=context, timeout=45) as response:
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
            logger.error(f"HTTPError: {e.code} {e.reason}")
            yield "I'm having trouble connecting to my core processing unit right now."
        except Exception as e:
            logger.error(f"Unexpected Error: {e}")
            yield "An unexpected error occurred while thinking."

