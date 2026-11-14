# kra-yazi

#### Yazi plugin for viewing Krita project files

<img width="1909" height="1020" alt="example" src="https://github.com/user-attachments/assets/b052d5fa-49ef-41ad-ad92-02a8bf46ef16" />

### Installation

1. Add the plugin via [ya](https://yazi-rs.github.io/docs/cli/):
  ```bash
  ya pkg add kastrbl4nik/kra
  ```

2. Update your yazi.toml config to enable the previewer:
  ```toml
  [plugin]
  prepend_previewers = [
      { url = "*.kra", run = "kra" },
  ]
  ```
