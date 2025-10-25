<!-- path: main.py -->
```python
import sys
from app.agent import Agent

if __name__ == "__main__":
    session_id = sys.argv[1]
    user_input = sys.argv[2]

    agent = Agent(session_id)
    response = agent.run(user_input)
    print(response)
```