
# bashgpt

**bashgpt** is a collection of Bash scripts that harness the power of OpenAI's ChatGPT API to automate tasks on Ubuntu. This project aims to simplify and accelerate daily tasks by integrating ChatGPT into custom Bash commands—perfect for developers, system administrators, or anyone looking to streamline operations directly from the terminal.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Project Structure](#project-structure)
- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Overview

**bashgpt** provides a set of Bash scripts designed to help you get work done on Ubuntu by leveraging ChatGPT's natural language processing capabilities. Whether you need to average benchmark results, perform system diagnostics, or automate other tasks, **bashgpt** makes it easy to extend your workflow with the power of AI.

## Features

- **OpenAI Integration:** Easily send commands and data to ChatGPT, getting back processed results to drive your workflow.
- **Modular Scripts:** Each script is self-contained, allowing you to pick and choose the tasks you need.
- **Ubuntu Focused:** Built specifically for Ubuntu environments with automatic dependency installation.
- **Easy Deployment:** An installer script moves all project scripts into your `~/bin` directory, ensuring they're available from anywhere in your terminal.
- **Scalable:** Designed to scale with additional scripts as you expand the project.

## Project Structure

```plaintext
bashgpt/
├── install_env.sh         # Installer script for dependencies and environment setup (Ubuntu-specific)
└── scripts/               # Directory containing various bash scripts powered by ChatGPT
    ├── run_bench_avg      # Example script: runs a benchmark executable 10 times and averages the results using ChatGPT
    └── new_script         # Placeholder for future scripts
```

## Installation

This project is designed exclusively for Ubuntu systems.

1. **Clone the repository:**

   ```bash
   git clone https://github.com/yourusername/bashgpt.git
   cd bashgpt
   ```

2. **Make the installer executable and run it:**

   ```bash
   chmod +x install_env.sh
   ./install_env.sh
   ```

   The installer will:
   - Verify your system is Ubuntu.
   - Install required dependencies (`jq` and `curl`) using `apt-get`.
   - Prompt you (up to 3 times) for your OpenAI API key and add it to your `~/.bashrc`.
   - Create a `~/bin` directory (if not already present) and add it to your PATH.
   - Copy all scripts from the `scripts/` directory into your `~/bin` directory and set executable permissions.

3. **Reload your shell configuration:**

   Either open a new terminal session or run:

   ```bash
   source ~/.bashrc
   ```

## Usage

Once installed, you can start using the scripts directly from your terminal.

For example, to run the benchmark averaging command:

```bash
run_bench_avg /path/to/your/benchmark_executable
```

Feel free to explore and add new scripts in the `scripts/` directory as your needs evolve. The installer will automatically deploy any new scripts when re-run.

## Contributing

Contributions are welcome! Whether it's new scripts or improvements to the installer, feel free to submit a pull request or open an issue.

1. Fork the repository.
2. Create your feature branch (`git checkout -b feature/my-new-script`).
3. Commit your changes (`git commit -am 'Add new script feature'`).
4. Push to the branch (`git push origin feature/my-new-script`).
5. Open a pull request describing your changes.

## License

This project is licensed under the Apache License. See the [LICENSE](LICENSE) file for details.

---

**bashgpt** is your go-to toolkit for integrating Bash with the power of OpenAI ChatGPT on Ubuntu. Enjoy automating your workflow with ease, and let us know if you have any ideas or improvements!
