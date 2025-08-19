<#

 .SYNOPSIS

Create new database in a docker container and stores the connection string in environment variable / clipboard


.DESCRIPTION

This script creates a new database in a Docker container running SQL Server. It generates a random hostname (if not specified) for the container and sets the SA password to the specified value. 
The connection string for the new database is stored in an environment variable / clipboard for easy access with provided name and underscore ending with ConnectionString
It will map host port 1434 by default to container port 1433, but you can change it via parameters.
example: NewDb_ConnectionString

.EXAMPLE

PS > New-Database.ps1 -DatabaseName "NewDb" -HostPort 1434

Creates a new database in a container with docker with name NewDb with random hostname and host port 1434 mapped to 1433. Command line will provide user interface to enter secure password.

.EXAMPLE

PS > New-Database.ps1 -DatabaseName "NewDb" -Overwrite

Creates a new database in a container with docker with name NewDb and random hostname and password for SA and overwrite existing instances. You will need to enter password from cli.
Creates a new database in a container with docker with name NewDb and random hostname and password for SA and overwrite existing instances. You will need to enter password from cli.

.EXAMPLE

PS > New-Database.ps1 -DatabaseName "NewDb" -InstanceName "sql1" -Overwrite

Creates a new database in a container with docker with name NewDb and instance name sql1 and overwrite existing instances. You will need to enter password from cli.

.EXAMPLE

PS > New-Database.ps1 -DatabaseName "NewDb" -InstanceName "sql1" -SaPwd "mypassword123!" -Overwrite

Creates a new database in a container with docker with name NewDb and instance name sql1 and password mypassword123!
 and overwrite existing instances. 
Creates a new database in a container with docker with name NewDb and instance name sql1 and overwrite existing instances. You will need to enter password from cli.

.EXAMPLE

PS > New-Database.ps1 -DatabaseName "NewDb" -InstanceName "sql1" -SaPwd "mypassword123!" -Overwrite

Creates a new database in a container with docker with name NewDb and instance name sql1 and password mypassword123!
 and overwrite existing instances. 

. LINK

http://github.com/vrhovnik
 
#>
[CmdletBinding(DefaultParameterSetName = "Containers")]
[Alias('cndb')]
param(
    [Parameter(Mandatory = $true)]
    $DatabaseName,
    [Parameter(Mandatory = $false)]
    $InstanceName,
    [Parameter(Mandatory = $true)]
    $SaPwd,
    [Parameter(Mandatory = $false)]
    [int]$HostPort = 1433,
    [Parameter(Mandatory = $false)]
    $ContainerName = "mcr.microsoft.com/mssql/server:2022-latest",
    $ContainerName = "mcr.microsoft.com/mssql/server:2022-latest",
    [Parameter(Mandatory = $false)]
    $PathToSqlScript,
    [Parameter(Mandatory = $false)]
    [Parameter(Mandatory = $false)]
    [switch]$Overwrite
)
$logPath = "$HOME/Downloads/create-new-database.log"
Start-Transcript -Path $logPath -Force

# List of action movie inspired names (lowercase, max 10 chars)
$actionNames = @(
    "matrix", "rambo", "bond", "blade", "rocky", "neo", "trinity", "maxpayne", "johnwick", "leeloo", "ripley", "mclane", "conan", "predator", "terminat0r"
)

if (-not $InstanceName) {
    $random = Get-Random -Minimum 0 -Maximum $actionNames.Count
    $InstanceName = $actionNames[$random]
    Write-Output "No instance name provided. Generated random name: $InstanceName"
}


# List of action movie inspired names (lowercase, max 10 chars)
$actionNames = @(
    "matrix", "rambo", "bond", "blade", "rocky", "neo", "trinity", "maxpayne", "johnwick", "leeloo", "ripley", "mclane", "conan", "predator", "terminat0r"
)

if (-not $InstanceName) {
    $random = Get-Random -Minimum 0 -Maximum $actionNames.Count
    $InstanceName = $actionNames[$random]
    Write-Output "No instance name provided. Generated random name: $InstanceName"
}

Write-Output "Creating new instance $InstanceName in container $ContainerName"
# Try to get Docker info
try {
    docker info 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Output "Docker is running."
        
    }
    else {
    }
    else {
        Write-Output "Docker is not running, please start Docker to create instance $InstanceName."
        Stop-Transcript
        Stop-Transcript
        return
    }
}
catch {
}
catch {
    Write-Output "Docker is not installed or not running. Check Docker installation."
    Stop-Transcript
    Stop-Transcript
    return
}

# check if password adhere to SQL password policy
function Test-SqlPasswordPolicy {
    param([string]$currentPwd)
    Write-Output "Testing SQL password policy for provided password."

    if ($currentPwd.Length -lt 8 -or $currentPwd.Length -gt 128) {
        Write-Output "Password must be between 8 and 128 characters."
    param([string]$currentPwd)
    Write-Output "Testing SQL password policy for provided password."

    if ($currentPwd.Length -lt 8 -or $currentPwd.Length -gt 128) {
        Write-Output "Password must be between 8 and 128 characters."
        return $false
    }
    $sets = 0
    if ($currentPwd -match '[A-Z]') { $sets++ }         # Uppercase
    if ($currentPwd -match '[a-z]') { $sets++ }         # Lowercase
    if ($currentPwd -match '\d') { $sets++ }            # Digit
    if ($currentPwd -match '[^a-zA-Z\d]') { $sets++ }   # Symbol
    Write-Output "Password contains $sets requirements."
    if ($currentPwd -match '[A-Z]') { $sets++ }         # Uppercase
    if ($currentPwd -match '[a-z]') { $sets++ }         # Lowercase
    if ($currentPwd -match '\d') { $sets++ }            # Digit
    if ($currentPwd -match '[^a-zA-Z\d]') { $sets++ }   # Symbol
    Write-Output "Password contains $sets requirements."
    return $sets -ge 3
}

if (-not (Test-SqlPasswordPolicy $SaPwd)) {
    Write-Output "Password does not meet SQL Server requirements. It must be 8-128 characters and contain at least three of: uppercase, lowercase, digit, symbol."
    Stop-Transcript
    Stop-Transcript
    return
}

# Check if container exists (running or stopped)
$existingContainer = docker ps -a --filter "name=$InstanceName" --format "{{.ID}}"

if ($existingContainer) {
    Write-Output "Container $InstanceName already exists. Checking if it should be overwritten."
    if ($Overwrite) {
        docker stop $InstanceName 2>$null
        docker rm $InstanceName 2>$null
        Write-Output "Container $InstanceName removed."
    }
    else {
    }
    else {
        Write-Output "Container $InstanceName exists and will not be overwritten."
        Stop-Transcript
        Stop-Transcript
        return
    }
} 

Write-Output "No existing container named $InstanceName, continuing creating new one with host port mapping $HostPort."
$hostPortToContainerPortMapping = "$($HostPort):1433"
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=$SaPwd" -p $hostPortToContainerPortMapping --name $InstanceName --hostname $InstanceName -d $ContainerName

$containerStatus = docker inspect -f '{{.State.Running}}' $InstanceName
if ($containerStatus -eq "true") {
    Write-Output "Container $InstanceName is running, continuing."
}
else {
    Write-Output "Container $InstanceName is NOT running, check logs."
    docker logs $InstanceName
    Stop-Transcript
    return
}

Write-Output "Creating new database $DatabaseName on $InstanceName"
docker exec -i $InstanceName /opt/mssql-tools18/bin/sqlcmd -No -S localhost -U sa -P "$SaPwd" -Q "CREATE DATABASE $DatabaseName"

# Check if database exists
$dbCheckCmd = "IF EXISTS (SELECT name FROM sys.databases WHERE name = N'$DatabaseName') SELECT 1 ELSE SELECT 0"
$dbExists = docker exec -i $InstanceName /opt/mssql-tools18/bin/sqlcmd -No -S localhost -U sa -P "$SaPwd" -Q "$dbCheckCmd"

if ($dbExists -match "1") {
    Write-Output "Database $DatabaseName exists in container $InstanceName."
}
else {
    Write-Output "Database $DatabaseName was NOT created successfully. Check logs."
    Stop-Transcript
    return
}
docker exec -i $InstanceName /opt/mssql-tools18/bin/sqlcmd -No -S localhost -U sa -P "$SaPwd" -Q "CREATE DATABASE $DatabaseName"

# Check if database exists
$dbCheckCmd = "IF EXISTS (SELECT name FROM sys.databases WHERE name = N'$DatabaseName') SELECT 1 ELSE SELECT 0"
$dbExists = docker exec -i $InstanceName /opt/mssql-tools18/bin/sqlcmd -No -S localhost -U sa -P "$SaPwd" -Q "$dbCheckCmd"

if ($dbExists -match "1") {
    Write-Output "Database $DatabaseName exists in container $InstanceName."
}
else {
    Write-Output "Database $DatabaseName was NOT created successfully. Check logs."
    Stop-Transcript
    return
}

if ($PathToSqlScript) {
    if (Test-Path $PathToSqlScript) {
        Write-Output "SQL script found at $PathToSqlScript. Executing in container $InstanceName..."
        docker exec -i $InstanceName /opt/mssql-tools18/bin/sqlcmd -No -S localhost -U sa -P "$SaPwd" -i "$PathToSqlScript"
        docker exec -i $InstanceName /opt/mssql-tools18/bin/sqlcmd -No -S localhost -U sa -P "$SaPwd" -i "$PathToSqlScript"
        if ($LASTEXITCODE -eq 0) {
            Write-Output "SQL script executed successfully in container $InstanceName."
        }
        else {
        }
        else {
            Write-Output "SQL script execution failed in container $InstanceName."
        }
    }
    else {
        Write-Output "SQL script file $PathToSqlScript does not exist, creating connection string for $DatabaseName."
    }
}

$connectionString = "Server=127.0.0.1,$HostPort;Database=$DatabaseName;User Id=sa;Password=$SaPwd;"
[Environment]::SetEnvironmentVariable("$($DatabaseName)_ConnectionString", $connectionString, "User")
    }
    else {
        Write-Output "SQL script file $PathToSqlScript does not exist, creating connection string for $DatabaseName."
    }
}

$connectionString = "Server=127.0.0.1,$HostPort;Database=$DatabaseName;User Id=sa;Password=$SaPwd;"
[Environment]::SetEnvironmentVariable("$($DatabaseName)_ConnectionString", $connectionString, "User")
Write-Output "Connection string for $DatabaseName stored in environment variable $($DatabaseName)_ConnectionString and copied to clipboard."
Write-Output $connectionString | Set-Clipboard
Stop-Transcript