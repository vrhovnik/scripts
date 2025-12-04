:: executecs.bat is a batch script to execute a C# script file using .NET
:: Usage: executecs.bat <path-to-csharp-script-file>
:: Open with in file explorer and set "Open with" to this script for cs files
:: Script is originally created by Tim Corey - https://www.youtube.com/watch?v=E9wrTsqP5h8
@echo off
:: gets the directory of the script and changes to it
cd /d "%~dp1"
:: runs the C# script file using dotnet
dotnet run "%~nx1"
:: pauses the command prompt to view output
pause