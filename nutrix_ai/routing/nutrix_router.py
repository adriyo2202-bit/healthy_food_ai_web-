import json
import urllib.request
import ssl
import logging
import re

logger = logging.getLogger(__name__)

HF_TOKEN = "SfruVWOyGjv45cMX5sbWLB2XbFUgEDlj"

class NutrixRouter:
    """
    Determines if a query requires RAG (Dietary Knowledge) or Web Search (Current Guidelines).
    """
    def __init__(self, api_key=HF_TOKEN):
        self.api_key = api_key

    def _call_llm_classification(self, query):
        """Uses API to classify the intent if rules aren't conclusive."""
        url = "https://api.mistral.ai/v1/chat/completions"
        headers = {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": f"Bearer {self.api_key}"
        }
        
        prompt = f"""Classify the user query into one or more of the following tags:
STABLE_KNOWLEDGE, CURRENT_INFORMATION, PERSONALIZED, RESEARCH, FOOD_SAFETY, NUTRITION, RECIPE, FITNESS, SLEEP, GENERAL.

Rules:
- If they ask what they should eat, how much they have eaten, or refer to themselves, use PERSONALIZED.
- If they ask for latest, recent, news, current guidelines, use CURRENT_INFORMATION.
- If they ask about basic definitions (What is protein, etc), use STABLE_KNOWLEDGE.
- If they ask about studies, evidence, research, use RESEARCH.
- If it's about FSSAI, safety, toxins, use FOOD_SAFETY.

Respond ONLY with a comma-separated list of tags.

Query: "{query}"
Tags:"""

        data = {
            "model": "mistral-small-latest",
            "messages": [{"role": "user", "content": prompt}],
            "temperature": 0.1,
        }
        
        req = urllib.request.Request(url, headers=headers, data=json.dumps(data).encode('utf-8'))
        
        try:
            context = ssl._create_unverified_context()
            with urllib.request.urlopen(req, context=context, timeout=15) as response:
                res_data = json.loads(response.read().decode('utf-8'))
                content = res_data['choices'][0]['message']['content'].strip()
                return [tag.strip().upper() for tag in content.split(',') if tag.strip()]
        except Exception as e:
            logger.error(f"Router LLM Error: {e}")
            return []

    def route(self, query, has_health_lens=False):
        """
        Determines the routing tags and booleans for system invocation.
        Returns a dictionary indicating which systems to use.
        """
        tags = set()
        q_lower = query.lower()
        
        # 1. Lightweight deterministic rules for obvious signals
        if any(word in q_lower for word in ['latest', 'recent', 'today', 'current', 'new']):
            tags.add('CURRENT_INFORMATION')
            
        if any(word in q_lower for word in ['i', 'my', 'me', 'tonight', 'have eaten']):
            tags.add('PERSONALIZED')
            
        if any(word in q_lower for word in ['research', 'study', 'studies', 'evidence']):
            tags.add('RESEARCH')
            
        if any(word in q_lower for word in ['fssai', 'safe', 'guideline', 'recall']):
            tags.add('FOOD_SAFETY')

        if has_health_lens and any(word in q_lower for word in ['this', 'scan', 'meal', 'it']):
            tags.add('PERSONALIZED')
            
        # 2. If it's completely ambiguous or lacks basic tags, use LLM
        if len(tags) == 0:
            llm_tags = self._call_llm_classification(query)
            tags.update(llm_tags)
            
        # Fallback if nothing matched
        if len(tags) == 0:
            tags.add('STABLE_KNOWLEDGE')
            tags.add('GENERAL')
            
        # Add STABLE_KNOWLEDGE by default if it's not strictly current/research only
        if 'NUTRITION' in tags or 'FOOD_SAFETY' in tags or 'RECIPE' in tags or 'FITNESS' in tags:
            tags.add('STABLE_KNOWLEDGE')

        # Map tags to specific systems
        use_rag = 'STABLE_KNOWLEDGE' in tags or 'NUTRITION' in tags or 'RECIPE' in tags
        use_web = 'CURRENT_INFORMATION' in tags or 'RESEARCH' in tags or ('FOOD_SAFETY' in tags and 'CURRENT_INFORMATION' in tags)
        use_user_context = 'PERSONALIZED' in tags or has_health_lens
        
        # Ensure at least RAG or Web is checked for general questions
        if not use_rag and not use_web and not use_user_context:
            use_rag = True
            tags.add('STABLE_KNOWLEDGE')

        return {
            'tags': list(tags),
            'use_rag': use_rag,
            'use_web': use_web,
            'use_user_context': use_user_context
        }
