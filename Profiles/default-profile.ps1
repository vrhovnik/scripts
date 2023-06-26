#ENV variables
$ENV:CHOCODIR="C:\ProgramData\chocolatey\lib\"
$ENV:WORKDIR="C:\Work"
$ENV:JMETER="$ENV:WORKDIR\Tools\apache-jmeter-5.5\bin"

Set-PSReadLineOption -PredictionSource HistoryAndPlugin -PredictionViewStyle InlineView
Set-PSReadLineKeyHandler -Chord F2 -Function SwitchPredictionView

# set aliases
Set-Alias -Name np -Value C:\Windows\notepad.exe
Set-Alias -Name k -Value kubectl
Function ShowAzAccounts(){ az account list --output table}
Set-Alias -Name azacc -value ShowAzAccounts

Function GetMyIP(){ Invoke-RestMethod http://ipinfo.io/json | Select-Object -ExpandProperty ip }
Set-Alias -Name myip -Value GetMyIP
Set-Alias wget -Value Invoke-WebRequest

#navigate and execute commands
Function GoToPowershellDir(){ 
    GoToProjects
    Set-Location "my-daily-scripts"
}
Set-Alias -Name pdir -Value GoToPowershellDir
Function GoHome(){ Set-Location $HOME}
Set-Alias -Name home -Value GoHome
Function GoToDownloads(){ Set-Location "$HOME\Downloads"}
Set-Alias -Name dwn -Value GoToDownloads
Function GoToWork(){ Set-Location $ENV:WORKDIR}
Set-Alias -Name work -Value GoToWork
Function GoToGithub(){ Set-Location "$ENV:WORKDIR\Github"}
Set-Alias -Name gdir -Value GoToGithub
Function GoToProjects(){ Set-Location "$ENV:WORKDIR\Projects"}
Set-Alias -Name proj -Value GoToProjects
Function GoToLocalTools(){ Set-Location "$ENV:WORKDIR\Tools"}
Set-Alias -Name tools -Value GoToLocalTools
Function GoToOneBack(){ Set-Location ..}
Set-Alias -Name .. -Value GoToOneBack
Function LoadLocalScript(){ 
	GoToPowershellDir
	.\System\Add-DirToSystemEnv.ps1 -RestartCurrentSession
	Write-Information "Script loaded"
	Set-Location $HOME
	Clear-Host
}
Set-Alias -Name lls -Value LoadLocalScript
Function GetGitLog(){ git log --graph --oneline}
Set-Alias -Name glog -Value GetGitLog
Function GetGitPrettyLog(){ git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative }
Set-Alias -Name gplog -Value GetGitPrettyLog
Function GoAdminFunc(){ 
	If (!([Security.Principal.WindowsPrincipal]	[Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator'))
	{
    	Start-Process -Verb RunAs wt.exe '-p "PowerShell"'
		Exit
	}
}
Set-Alias -Name goadmin -Value GoAdminFunc
Function OpenGodModeFolder(){ 
	Set-Location "$ENV:OneDrive\Desktop\GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}"
	Write-Information "Opened Desktop folder"
	Start-Process Explorer .
	Set-Location $HOME
	Clear-Host
}
Set-Alias -Name godmode -Value OpenGodModeFolder
Function FreeDiskFolder(){ 
	Set-Location "$ENV:OneDrive"
	Write-Information "Opened Desktop folder"
	Start-Process '.\Free up disk space by deleting unnecessary files - Shortcut.lnk'
	Set-Location $HOME
	Clear-Host
}
Set-Alias -Name freeme -Value FreeDiskFolder

## import modules
Import-Module posh-git
Import-Module -Name Terminal-Icons
oh-my-posh init pwsh --config "$ENV:POSH_THEMES_PATH\material.omp.json" | Invoke-Expression
Clear-Host