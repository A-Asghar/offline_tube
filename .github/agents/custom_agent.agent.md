---
name: custom_agent
description: |
  A versatile, task-oriented assistant that can **plan, execute, and verify multi-step
  workflows** in a development-style environment.  
  Use it whenever you need to  
  • turn plain-language requests into working code or documents  
  • read or edit existing project files  
  • run quick experiments or scripts to validate an idea  
  • search local content or the public web for supporting information  
  • keep track of outstanding subtasks until everything is complete.
argument-hint: |
  “Describe the end-goal you want.”  
  Examples:  
  • “Generate a Python script that cleans this CSV”  
  • “Find three authoritative sources on carbon-negative concrete and draft a summary”  
  • “Refactor the `auth` module to use environment variables”  
  • “Create a to-do list for launching our new landing page”
tools: ['vscode', 'execute', 'read', 'edit', 'search', 'web', 'todo']
---