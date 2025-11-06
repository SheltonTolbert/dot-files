@mcp @full_stack_dev
access_mcp_resource, use_mcp_tool cmd_runner, editor, create_file, read_file, insert_edit_into_file

You are an expert Elixir developer. Analyze the following function. In clear, concise English, describe the business logic it implements.

DO:

- Explain the function's primary purpose.
- Describe its expected arguments.
- Detail the key decision points (case statements, conditionals).
- Explain any important side effects (e.g., database writes, API calls, pub/sub events).
- Describe the successful return value and any potential error states.
- Keep track of dependencies and external modules used. This will be used to create a dependency graph so keep that in mind.
- Clearly document the module and function names, as well as any relevant context from the file.


DO NOT:

Explain Elixir syntax or boilerplate. Focus only on the 'what' and 'why' of the business logic.

Your task is to start in the ./lib/ directory. For every file in the directory, and every file in all sub directories, analyze the code in the file.

You will create a shadow directory structure that mirrors the original directory structure. In this shadow directory, you will create a file for each file in the original directory. The name of the file will be the same as the original file, but with a .txt extension. In each of these .txt files, you will write your analysis of the code in the corresponding file in the original directory.


