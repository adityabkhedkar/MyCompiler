# Test script for CStar Lexer
Write-Host "Running CStar Lexer Tests..." -ForegroundColor Cyan

# Ensure we're in the right directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location (Split-Path -Parent $scriptPath)

# Function to run a test case
function Run-Test {
    param (
        [string]$testFile,
        [string]$expectedFile
    )
    
    Write-Host "`nTesting file: $testFile" -ForegroundColor Yellow
    
    # Check if test file exists
    if (-not (Test-Path $testFile)) {
        Write-Host "Error: Test file $testFile not found!" -ForegroundColor Red
        return $false
    }
    
    # Run the lexer and capture output
    $output = Get-Content $testFile | .\lexer.exe
    
    # If expected file exists, compare output
    if (Test-Path $expectedFile) {
        $expected = Get-Content $expectedFile
        $differences = Compare-Object $output $expected
        
        if ($differences) {
            Write-Host "Test Failed! Output differs from expected:" -ForegroundColor Red
            $differences | ForEach-Object {
                if ($_.SideIndicator -eq "<=") {
                    Write-Host "Expected: $($_.InputObject)" -ForegroundColor Green
                } else {
                    Write-Host "Got: $($_.InputObject)" -ForegroundColor Red
                }
            }
            return $false
        } else {
            Write-Host "Test Passed!" -ForegroundColor Green
            return $true
        }
    } else {
        # If no expected file exists, just display the output
        Write-Host "No expected output file found. Displaying lexer output:"
        $output | ForEach-Object { Write-Host $_ }
        return $true
    }
}

# Create test results directory if it doesn't exist
$resultsDir = "output"
if (-not (Test-Path $resultsDir)) {
    New-Item -ItemType Directory -Path $resultsDir | Out-Null
}

# Array of test cases
$testCases = @(
    @{
        Input = "input\tests\basic.c"
        Expected = "tests\expected\basic.exp"
    },
    @{
        Input = "input\tests\float.c"
        Expected = "tests\expected\float.exp"
    },
    @{
        Input = "input\tests\error_test.c"
        Expected = "tests\expected\error_test.exp"
    },
    @{
        Input = "input\tests\test1.c"
        Expected = "tests\expected\test1.exp"
    }
)

# Run all tests
$passedTests = 0
$totalTests = $testCases.Count

foreach ($test in $testCases) {
    if (Run-Test -testFile $test.Input -expectedFile $test.Expected) {
        $passedTests++
    }
}

# Print summary
Write-Host "`nTest Summary:" -ForegroundColor Cyan
Write-Host "Total Tests: $totalTests"
Write-Host "Passed: $passedTests"
Write-Host "Failed: $($totalTests - $passedTests)"

# Exit with appropriate code
if ($passedTests -eq $totalTests) {
    Write-Host "`nAll tests passed!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`nSome tests failed!" -ForegroundColor Red
    exit 1
}