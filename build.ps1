# Build script for CStar Compiler on Windows
Write-Host "Building CStar Compiler..." -ForegroundColor Cyan

# Ensure we're in the right directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

# Create build directory if it doesn't exist
if (-not (Test-Path "build")) {
    New-Item -ItemType Directory -Path "build"
}

# Check for required tools
$tools = @{
    "win_flex" = "Flex"
    "win_bison" = "Bison"
    "gcc" = "GCC"
}

foreach ($tool in $tools.Keys) {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
        Write-Host "Error: $($tools[$tool]) is not installed or not in PATH!" -ForegroundColor Red
        Write-Host "Please install MinGW and WinFlexBison to build the compiler." -ForegroundColor Yellow
        exit 1
    }
}

# Run bison to generate parser
Write-Host "Generating parser..." -ForegroundColor Yellow
win_bison -d -o parser.tab.c parser.y
if (-not $?) {
    Write-Host "Error: Bison failed!" -ForegroundColor Red
    exit 1
}

# Run flex to generate lexer
Write-Host "Generating lexer..." -ForegroundColor Yellow
win_flex -o lex.yy.c lexer.l
if (-not $?) {
    Write-Host "Error: Flex failed!" -ForegroundColor Red
    exit 1
}

# Compile everything with proper include paths
Write-Host "Compiling..." -ForegroundColor Yellow
gcc -Wall -I. -o build/compiler.exe lex.yy.c parser.tab.c src/main.c
if (-not $?) {
    Write-Host "Error: Compilation failed!" -ForegroundColor Red
    exit 1
}

Write-Host "`nBuild successful! Executable is at build/compiler.exe" -ForegroundColor Green