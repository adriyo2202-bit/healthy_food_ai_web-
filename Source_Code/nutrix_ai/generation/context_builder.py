class ContextBuilder:
    """
    Builds the final prompt context by combining RAG chunks, Web chunks, User Context, and Chat History.
    """
    def build(self, query, user_context_dict, rag_results, web_results, off_results=None, chat_history=None):
        context_blocks = []
        if chat_history is None:
            chat_history = []
        
        if user_context_dict:
            u_str = "[PRIVATE USER CONTEXT]\n"
            if 'nutrition' in user_context_dict:
                nut = user_context_dict['nutrition']
                u_str += f"Goal: {nut['goal']} ({nut.get('diet_type', 'General')} Diet)\n"
                u_str += f"Bio: Age {nut.get('age')}, Weight {nut.get('weight_kg')}kg, Height {nut.get('height_cm')}cm\n"
            if 'active_diet_plan' in user_context_dict:
                import json
                u_str += f"**CURRENT ACTIVE DIET PLAN**: {json.dumps(user_context_dict['active_diet_plan'], indent=2)}\n"
            if 'recent_scans' in user_context_dict:
                import json
                u_str += f"**RECENTLY SCANNED LABELS**: {json.dumps(user_context_dict['recent_scans'], indent=2)}\n"
            if 'fitness' in user_context_dict:
                u_str += f"Fitness: {user_context_dict['fitness']}\n"
            if 'health_lens' in user_context_dict:
                u_str += f"Health Lens Scan: {user_context_dict['health_lens']}\n"
            context_blocks.append(u_str)
            
        if rag_results:
            rag_str = "[STABLE KNOWLEDGE / RAG]\n"
            for i, r in enumerate(rag_results):
                rag_str += f"--- Document {i+1} ---\n{r['content']}\n"
            context_blocks.append(rag_str)
            
        if off_results:
            off_str = "[OPEN FOOD FACTS DATABASE]\n"
            for i, r in enumerate(off_results):
                off_str += f"--- Source: {r.get('title', 'Product')} ---\n"
                off_str += f"{r['content']}\n"
            context_blocks.append(off_str)
            
        if web_results:
            web_str = "[CURRENT WEB SEARCH RESULTS]\n"
            for i, r in enumerate(web_results):
                # Never show mock documents to the user as real sources in citations.
                # We can feed the content to the LLM but we strip the URL so the LLM can't cite a fake URL.
                is_mock = r.get('is_mock', False)
                url = "Mock Data - Do not cite URL" if is_mock else r.get('url', 'Unknown URL')
                title = r.get('title', 'Unknown')
                
                web_str += f"--- Source: {title} ({url}) ---\n"
                if r.get('published_at'):
                    web_str += f"Published: {r['published_at']}\n"
                web_str += f"{r['content']}\n"
            context_blocks.append(web_str)
            
        final_context = "\n\n".join(context_blocks)
        
        system_prompt = f"""You are Nutrix, an extremely polite, highly intelligent conversational health and nutrition assistant.
Your goal is to answer the user's question using the provided context, delivering your answers with a highly authoritative and strong verdict, especially regarding ingredient safety and health risks.

Important rules:
1. Base your answer primarily on the provided context (RAG, Web, and User data) if it contains the answer.
2. If the provided database extracts do NOT contain the answer, you must gracefully fall back to your own extensive internal medical and nutritional knowledge to answer the user's question, but clarify that you are drawing on general knowledge.
3. For Personalized Queries, treat the "REMAINING TODAY" values as absolute mathematical truth. Do NOT calculate values yourself. If a suggested food exceeds the remaining targets, explicitly caution the user. 
4. Be exceptionally polite in your greetings and conversational flow, but absolutely firm, decisive, and authoritative when providing health or safety verdicts. Do not use wishy-washy language for ingredient safety.
5. DO NOT invent medical diagnoses or unsafe treatments.
6. Keep your tone natural and conversational. Do not expose internal mechanics like "I retrieved 5 vectors".
7. If you use information from a Web Source or RAG database, cite it naturally (e.g., "According to the safety rules..."). Do NOT cite any URL marked as "Mock Data".
8. CULTURAL ALIGNMENT: Tailor all diet plans, food suggestions, recipes, and dietary analysis specifically to Indian cuisine, dietary habits, and cultural context (e.g., using regional names like Poha, Chana, Dal, Macher Jhol, Mishti Doi, etc.) by default, unless the user explicitly requests otherwise.
9. FORMATTING: Use a beautiful, highly readable format. When generating meal plans, use structured headers (e.g., Breakfast, Mid-Morning Snack, Lunch, Evening Snack). Include bullet points detailing the traditional Indian dish, a brief explanation of its nutritional balance, and an estimate of the calories and macros (Protein, Fat, Carbs). Use bolding for emphasis.
10. DIRECT ANSWERS: Focus on providing the output immediately rather than asking the user many follow-up questions. Give them a comprehensive, beautifully formatted response right away.

==== CONTEXT START ====
{final_context}
==== CONTEXT END ====
"""
        messages = [{"role": "system", "content": system_prompt}]
        
        # Add recent conversation history (max 4 messages to avoid context bloat)
        for msg in chat_history[-4:]:
            messages.append(msg)
            
        messages.append({"role": "user", "content": query})
        
        return messages
