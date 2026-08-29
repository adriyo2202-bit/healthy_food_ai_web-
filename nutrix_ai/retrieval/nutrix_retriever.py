from .hybrid_search import HybridSearch
from .reranker import Reranker

class NutrixRetriever:
    """
    Main retrieval interface that combines HybridSearch and Reranking.
    """
    def __init__(self, keyword_index, vector_store):
        self.hybrid_search = HybridSearch(keyword_index, vector_store)
        self.reranker = Reranker()

    def retrieve(self, query, intent_tags, initial_k=20, final_k=5):
        """
        Retrieves documents based on query and intents.
        """
        # 1. Fetch Candidates (Hybrid)
        candidates = self.hybrid_search.search(query, top_k=initial_k)
        
        # 2. Rerank (returns dict with results and is_stale)
        rerank_output = self.reranker.rerank(candidates, intent_tags, top_k=final_k)
        
        return rerank_output
