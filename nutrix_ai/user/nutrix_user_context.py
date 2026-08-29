class NutrixUserContext:
    """
    Mock service to simulate retrieving user-specific health and diet context.
    Now uses deterministic calculations instead of forcing the LLM to do arithmetic.
    """
    def __init__(self):
        # Mocked database of users
        self.users = {
            "user_A": {
                "name": "User A",
                "goal": "High Protein",
                "calorie_target": 2100,
                "protein_target": 100,
                "carbs_target": 200,
                "fat_target": 70,
                "consumed_calories": 1640,
                "consumed_protein": 86,
                "consumed_carbs": 180,
                "consumed_fat": 60,
                "steps": 7420,
                "recent_meals": ["Chicken Biryani"]
            },
            "user_B": {
                "name": "User B",
                "goal": "Weight Loss",
                "calorie_target": 1800,
                "protein_target": 80,
                "carbs_target": 150,
                "fat_target": 55,
                "consumed_calories": 1750,
                "consumed_protein": 75,
                "consumed_carbs": 140,
                "consumed_fat": 50,
                "steps": 12000,
                "recent_meals": ["Oatmeal", "Salad"]
            }
        }
        
        self.health_lens = None
        self.fitness_lens = None

    def set_health_lens_context(self, food_data):
        self.health_lens = food_data
        
    def set_fitness_lens_context(self, fitness_data):
        self.fitness_lens = fitness_data

    def get_context(self, user_id, intent_tags):
        """
        Returns a structured dictionary of deterministic calculations.
        """
        if user_id not in self.users:
            return None
            
        u = self.users[user_id]
        context_data = {}
        
        if 'PERSONALIZED' in intent_tags or 'NUTRITION' in intent_tags:
            # Deterministic Calculator Layer
            rem_cal = max(0, u['calorie_target'] - u['consumed_calories'])
            rem_pro = max(0, u['protein_target'] - u['consumed_protein'])
            rem_carbs = max(0, u['carbs_target'] - u['consumed_carbs'])
            rem_fat = max(0, u['fat_target'] - u['consumed_fat'])
            
            context_data['nutrition'] = {
                "goal": u['goal'],
                "targets": {
                    "calories": u['calorie_target'],
                    "protein": f"{u['protein_target']}g",
                    "carbs": f"{u['carbs_target']}g",
                    "fat": f"{u['fat_target']}g"
                },
                "consumed": {
                    "calories": u['consumed_calories'],
                    "protein": f"{u['consumed_protein']}g",
                    "carbs": f"{u['consumed_carbs']}g",
                    "fat": f"{u['consumed_fat']}g"
                },
                "remaining_today": {
                    "calories": rem_cal,
                    "protein": f"{rem_pro}g",
                    "carbs": f"{rem_carbs}g",
                    "fat": f"{rem_fat}g"
                },
                "recent_meals": u['recent_meals']
            }
            
        if 'FITNESS' in intent_tags:
            context_data['fitness'] = {
                "steps_today": u['steps']
            }
            if self.fitness_lens:
                context_data['fitness']['recent_workout'] = self.fitness_lens
                
        if self.health_lens:
            context_data['health_lens'] = self.health_lens
            
        if not context_data:
            return None
            
        return context_data
