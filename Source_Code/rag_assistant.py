import os
import urllib.request
import urllib.error
import urllib.parse
import json
import xml.etree.ElementTree as ET
import math
import ssl

HF_TOKEN = "SfruVWOyGjv45cMX5sbWLB2XbFUgEDlj"

def get_mistral_embedding(text, api_key=HF_TOKEN):
    url = "https://api.mistral.ai/v1/embeddings"
    headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": f"Bearer {api_key}"
    }
    data = {
        "model": "mistral-embed",
        "input": [text]
    }
    req = urllib.request.Request(url, headers=headers, data=json.dumps(data).encode('utf-8'))
    try:
        context = ssl._create_unverified_context()
        with urllib.request.urlopen(req, context=context, timeout=30) as response:
            res_data = json.loads(response.read().decode('utf-8'))
            return res_data["data"][0]["embedding"]
    except Exception as e:
        print(f"[Error getting embedding]: {e}")
        return None

def cosine_similarity(v1, v2):
    dot_product = sum(a * b for a, b in zip(v1, v2))
    magnitude1 = math.sqrt(sum(a * a for a in v1))
    magnitude2 = math.sqrt(sum(b * b for b in v2))
    if magnitude1 == 0 or magnitude2 == 0:
        return 0.0
    return dot_product / (magnitude1 * magnitude2)

class VectorStore:
    def __init__(self):
        self.documents = []
        self.embeddings = []

    def add_document(self, text):
        emb = get_mistral_embedding(text)
        if emb:
            self.documents.append(text)
            self.embeddings.append(emb)

    def search(self, query, top_k=2):
        if not self.documents:
            return []
        query_emb = get_mistral_embedding(query)
        if not query_emb:
            return []
        
        scores = []
        for i, emb in enumerate(self.embeddings):
            score = cosine_similarity(query_emb, emb)
            scores.append((score, self.documents[i]))
            
        scores.sort(key=lambda x: x[0], reverse=True)
        return [doc for score, doc in scores[:top_k]]

def fetch_arxiv_papers(query, max_results=2):
    print(f"\n[Searching ArXiv for '{query}'...]")
    search_query = urllib.parse.quote(query)
    url = f"http://export.arxiv.org/api/query?search_query=all:{search_query}&start=0&max_results={max_results}"
    
    try:
        context = ssl._create_unverified_context()
        with urllib.request.urlopen(url, context=context, timeout=30) as response:
            xml_data = response.read()
            root = ET.fromstring(xml_data)
            
            # XML namespace for atom
            ns = {'atom': 'http://www.w3.org/2005/Atom'}
            papers = []
            for entry in root.findall('atom:entry', ns):
                title = entry.find('atom:title', ns).text.strip()
                summary = entry.find('atom:summary', ns).text.strip()
                papers.append(f"Title: {title}\nAbstract: {summary}")
            return papers
    except Exception as e:
        print(f"[Error fetching from ArXiv]: {e}")
        return []

def get_mistral_chat_completion(messages, api_key=HF_TOKEN):
    url = "https://api.mistral.ai/v1/chat/completions"
    headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": f"Bearer {api_key}"
    }
    
    data = {
        "model": "mistral-small-latest",
        "messages": messages,
        "temperature": 0.7,
        "stream": True
    }
    
    req = urllib.request.Request(url, headers=headers, data=json.dumps(data).encode('utf-8'))
    
    try:
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
        yield None
    except Exception as e:
        print(f"\n[Unexpected Error]: {e}")
        yield None

def main():
    print("Welcome to your RAG-powered AI Assistant!")
    print("I can fetch relevant research papers from ArXiv to answer your questions.")
    print("Type 'exit' or 'quit' to end the chat.\n")
    
    vector_store = VectorStore()
    
    system_prompt = """You are a helpful, knowledgeable AI assistant with access to research papers.
Use the provided context to answer the user's questions accurately.
If the provided context does not contain the answer, you can rely on your general knowledge but mention that it's not from the retrieved papers.
Keep your tone conversational and helpful."""

    # We'll maintain a rolling window of conversation history (e.g., last 4 messages)
    # plus the system prompt and the current context.
    chat_history = [] 

    print("\nAssistant: Hello! What topic would you like to research or discuss today?")
    
    while True:
        try:
            user_input = input("\nYou: ").strip()
            
            if user_input.lower() in ['exit', 'quit']:
                print("\nAssistant: Goodbye! Have a great day!")
                break
                
            if not user_input:
                continue
                
            # 1. Fetch new data if it's a substantive query
            if len(user_input.split()) > 2: 
                new_papers = fetch_arxiv_papers(user_input, max_results=2)
                for paper in new_papers:
                    vector_store.add_document(paper)
            
            # 2. Retrieve relevant context from our local vector store
            relevant_docs = vector_store.search(user_input, top_k=2)
            context_str = "\n\n".join(relevant_docs)
            
            # 3. Construct the prompt with context and history
            messages = [{"role": "system", "content": system_prompt}]
            
            # Add context if available
            if context_str:
                context_message = f"Here is some relevant information from research papers to help you answer:\n{context_str}\n\nPlease use this context if it's relevant to the following user query."
                messages.append({"role": "system", "content": context_message})
                
            # Add chat history (rolling window of last 4 messages)
            messages.extend(chat_history[-4:])
            
            # Add current user input
            messages.append({"role": "user", "content": user_input})
            
            # 4. Generate response
            print("Assistant: ", end="", flush=True)
            generator = get_mistral_chat_completion(messages)
            
            reply = ""
            for chunk in generator:
                if chunk is None:
                    reply = None
                    break
                print(chunk, end="", flush=True)
                reply += chunk
                
            print()
            
            if reply:
                # Update memory
                chat_history.append({"role": "user", "content": user_input})
                chat_history.append({"role": "assistant", "content": reply})
                
        except KeyboardInterrupt:
            print("\n\nAssistant: Goodbye!")
            break
        except Exception as e:
            print(f"\nAn error occurred: {e}")

if __name__ == "__main__":
    main()
