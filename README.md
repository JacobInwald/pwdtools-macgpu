# pwdtools-macgpu

A GPU-accelerated password cracking tool that utilizes the Metal framework for parallel computations. It provides a brute force engine for cracking passwords.

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

1. Modify the `constants.h` and `md5GPU.h` file to set the character set and character set length to use.

2. Build the project.

3. Navigate to the exes directory and run ```./pwdcrack <hash> <search depth>```

4. Wait for it to finish!!

## Contributing

Contributions are welcome! If you find any issues or have suggestions for improvements, please open an issue or submit a pull request.
