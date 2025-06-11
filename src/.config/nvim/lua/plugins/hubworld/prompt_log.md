## Me

Please provide a detailed plan for completing the task, including all necessary steps and considerations. Here is the list of tools that you can use:

1. @full_stack_dev
2. @mcp

Your task is to develop a neovim plugin called Hubworld.

Hubworld is a neovim plugin that allows users to manage and interact with multiple repositories and projects seamlessly. The plugin should provide features such as repository management, project switching, and integration with version control systems.

For the first version, we will focus on the following features:
- Project management: Create, delete, and switch between projects.
  - Projects can be existing directories or git repositories.
  - New projects can also be initialized as git repositories.
- Hubworld UI: A user-friendly interface to manage projects and repositories.
  - Using telescope.nvim for the UI, Hubworld will feature several views:
    - Project list view
    - Repository details view
    - Project creation and deletion view
    - Github search view
  - For this version, we will focus on the project list view.
- Project list view: Display a list of projects with the option to switch between them.
  - The project list should show the project name, path, and status (e.g., git repository).
  - Users should be able to select a project to switch to it.
  - Upon switching, the plugin should update the current working directory, clear the buffer, and reload the last opened buffers and panes for the selected project.
    - You'll need to store state in a configuration file or a similar mechanism to remember the last opened buffers and panes for each project. We will want this to be persistent across Neovim sessions.
    - The data structure may look like this:
      ```lua
      {
        project_name = {
          path = "/path/to/project",
          last_opened_buffers = { "file1.lua", "file2.lua" },
          last_opened_panes = { {buffer: "buffer", position: "position", size: "size"}, ...}
        }
      }
      ```


