class ContextBuilder:
    """
    Builds the final prompt context by combining RAG chunks, Web chunks, User Context, and Chat History.
    """
    def build(self, query, user_context_dict, rag_results, web_results, chat_history):
        context_blocks = []
        
        if user_context_dict:
            u_str = "[PRIVATE USER CONTEXT]\n"
            if 'nutrition' in user_context_dict:
                nut = user_context_dict['nutrition']
                u_str += f"Goal: {nut['goal']}\n"
                u_str += f"Targets: {nut['targets']}\n"
                u_str += f"Consumed: {nut['consumed']}\n"
                u_str += f"**REMAINING TODAY (Absolute Truth)**: {nut['remaining_today']}\n"
                u_str += f"Recent Meals: {', '.join(nut['recent_meals'])}\n"
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
        
        system_prompt = f"""You are Nutrix, an intelligent conversational health and nutrition assistant.
Your goal is to answer the user's question using the provided context. 

Important rules:
1. Base your answer primarily on the provided context (RAG, Web, and User data).
2. For Personalized Queries, treat the "REMAINING TODAY" values as absolute mathematical truth. Do NOT calculate values yourself. If a suggested food exceeds the remaining targets, explicitly caution the user. 
3. If web search results are provided, use them for current/recent facts. If no current info is available but the user asked for it, say "I couldn't verify a sufficiently recent authoritative source for this." Do not claim something is the "latest" without evidence.
4. If the context is insufficient, state that you don't have enough reliable information to answer confidently.
5. DO NOT invent medical diagnoses or unsafe treatments.
6. Keep your tone natural, helpful, and conversational. Do not expose internal mechanics like "I retrieved 5 vectors".
7. If you use information from a Web Source, cite it naturally (e.g., "According to FSSAI guidelines..."). Do NOT cite any URL marked as "Mock Data".

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
