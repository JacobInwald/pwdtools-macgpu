# pwdtools-macgpu

The `pwdtools-gpu` project is a GPU-based password cracking tool that utilizes the Metal framework for parallel computations. It provides a brute force engine for cracking passwords.

## Features

- Utilizes Metal framework for GPU parallel computations
- Performs brute force password cracking
- Supports custom character sets and password lengths

## Requirements

- macOS 10.15 or later
- Xcode 12 or later

## Installation

1. Clone the repository:

    ```shell
    git clone https://github.com/your-username/pwdtools-gpu.git
    ```

2. Open the project in Xcode.

3. Build and run the project.

## Usage

1. Modify the `constants.h` file to set the desired password length and character set, ensure these changes are reflected in the `pwdcrack.metal` file.

2. Run the project.

3. The program will start cracking passwords using the GPU. The progress and estimated time remaining will be displayed in the console.

## Contributing

Contributions are welcome! If you find any issues or have suggestions for improvements, please open an issue or submit a pull request.
