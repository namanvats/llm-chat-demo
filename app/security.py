import re
from typing import Tuple, List

class PromptInjectionDetector:
    PATTERNS = [
        #1. System Overrides
        (r"ignore\s+(previous|all|prior)\s+instructions?", "System override"),

       #2. System overrise erasing content
       (r"forget\s+(all|everything|previous)", "Content erasure"),

       #3. Role Manipulation
       (r"you\s+are\s+(now|acting|replacing|assuming)\s+the\s+role\s+of\s+(\w+)", "Role manipulation"),

       #4. Role Manipulation trying to change behaviour
       (r"act\s+as\s+(a\s)?(hacker|villian|doctor|evil|)", "Role change"),

       #5. Jailbreaking instructions
       (r"(DAN|developer)\s+mode", "Jailbreaking"),

       #6. Prompt Extractions
       (r"(show|reveal|print|echo)\s+(the\s+prompt|the\s+instructions|the\s+system\s+prompt)", "Prompt extraction"),
    ]

    def __init__(self, max_length=5000):
        self.max_length = max_length
        self.compiled_patterns = [
            (re.compile(pattern, re.IGNORECASE), reason) 
            for pattern, reason in self.PATTERNS
        ]
    
    def detect(self, user_input: str) -> Tuple[bool, List[str]]:
        if not user_input:
            return False, []
        
        reasons = []

        if len(user_input) > self.max_length:
            reasons.append("Input too long")
        
        # Check Patterns
        for pattern, reason in self.compiled_patterns:
            if pattern.search(user_input):
                reasons.append(reason)
        
        return len(reasons) > 0, reasons      
