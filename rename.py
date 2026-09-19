import os

files = [
    'lib/main.dart',
    'lib/splash_screen.dart',
    'lib/prototype_web_sim.dart'
]

for filepath in files:
    with open(filepath, 'r') as f:
        content = f.read()
    
    # 1. Replace exact uppercase string
    content = content.replace('WEBSIM AI', 'HEALTHY FOOD AI')
    content = content.replace('WEBSIM VISION', 'HEALTHY FOOD VISION')
    
    # 2. Replace exact title case string
    content = content.replace('WebSim AI', 'Healthy Food AI')
    
    # 3. Replace standalone WebSim in text
    content = content.replace('Ask WebSim', 'Ask Healthy Food AI')
    content = content.replace('let WebSim', 'let Healthy Food AI')
    content = content.replace('WebSim combines', 'Healthy Food AI combines')
    content = content.replace('Open WebSim', 'Open Healthy Food AI')
    content = content.replace('WebSim Vision', 'Healthy Food Vision')
    
    # 4. Replace class names / prefixes
    content = content.replace('WebSim', 'HealthyFood')
    
    with open(filepath, 'w') as f:
        f.write(content)

print("Done")
