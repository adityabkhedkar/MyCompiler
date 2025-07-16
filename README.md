# MyCompiler

A simple C-like language compiler project.

## Features
- Lexical analysis (lexer)
- Syntax analysis (parser)
- AST generation
- Intermediate code (TAC) generation
- Automated tests

## Project Structure
- `src/` - Source code
- `include/` - Header files
- `input/` - Test input files
- `output/` - Output files (AST, TAC, etc.)
- `tests/` - Test scripts and expected outputs
- `build.ps1` - PowerShell build script
- `Makefile` - Makefile for Unix-like systems

## Build Instructions
### Windows (PowerShell)
```powershell
powershell -ExecutionPolicy Bypass -File build.ps1
```

### Unix/Linux (Make)
```sh
make
```

## Running Tests
### Windows
```powershell
powershell -ExecutionPolicy Bypass -File tests/test.ps1
```

### Unix/Linux
```sh
./tests/tests.sh
```

## Usage
- The compiler executable will be generated in the `build/` directory as `compiler.exe` (Windows) or `compiler` (Unix).
- Run the compiler with your source file as input.

## License
MIT 