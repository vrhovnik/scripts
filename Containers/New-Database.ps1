<#

 .SYNOPSIS

Create new database in a docker container and stores the connection string in environment variable / clipboard


.DESCRIPTION

This script creates a new database in a Docker container running SQL Server. It generates a random hostname (if not specified) for the container and sets the SA password to the specified value. 
The connection string for the new database is stored in an environment variable / clipboard for easy access with provided name and underscore ending with ConnectionString

example: NewDb_ConnectionString

.EXAMPLE

PS > New-Database.ps1 -DatabaseName "NewDb" 

Creates a new database in a container with docker with name NewDb with random hostname. Command line will provide user interface to enter secure password.

.EXAMPLE

PS > New-Database.ps1 -DatabaseName "NewDb" -Overwrite

Creates a new database in a container with docker with name NewDb and random hostname and password for SA and overwrite existing instances. You will need to enter secure password.

.EXAMPLE

PS > New-Database.ps1 -DatabaseName "NewDb" -InstanceName "sql1" -Overwrite

Creates a new database in a container with docker with name NewDb and instance name sql1 and overwrite existing instances. You will need to enter secure password.

. LINK

http://github.com/vrhovnik
 
#>
[CmdletBinding(DefaultParameterSetName = "Containers")]
[Alias('cndb')]
param(
    [Parameter(Mandatory = $true)]
    $DatabaseName,
    [Parameter(Mandatory = $true)]
    [SecureString]$SaPwd,
    [Parameter(Mandatory = $false)]
    $InstanceName,
    [Parameter(Mandatory = $false)]
    $ContainerName="mcr.microsoft.com/mssql/server:2022-latest",
    [Parameter(Mandatory = $false)]
    $PathToSqlScript,
    [Parameter(Mandatory=$false)]
    [switch]$Overwrite
)
$logPath = "$HOME/Downloads/create-new-database.log"
Start-Transcript -Path $logPath -Force
Write-Output "Creating new instance $InstanceName in container $ContainerName"
# Try to get Docker info
try {
    docker info 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Output "Docker is running."
        
    } else {
        Write-Output "Docker is not running, please start Docker to create instance $InstanceName."
        return
    }
} catch {
    Write-Output "Docker is not installed or not running. Check Docker installation."
    return
}

# check if password adhere to SQL password policy
function Test-SqlPasswordPolicy {
    param([securestring]$Password)
    $currentPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
    if ($currentPassword.Length -lt 8 -or $currentPassword.Length -gt 128) {
        return $false
    }
    $sets = 0
    if ($Password -match '[A-Z]') { $sets++ }         # Uppercase
    if ($Password -match '[a-z]') { $sets++ }         # Lowercase
    if ($Password -match '\d') { $sets++ }            # Digit
    if ($Password -match '[^a-zA-Z\d]') { $sets++ }   # Symbol
    return $sets -ge 3
}

if (-not (Test-SqlPasswordPolicy $SaPwd)) {
    Write-Output "Password does not meet SQL Server requirements. It must be 8-128 characters and contain at least three of: uppercase, lowercase, digit, symbol."
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
    } else {
        Write-Output "Container $InstanceName exists and will not be overwritten."
        return
    }
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

Write-Output "No existing container named $InstanceName, continuing creating new one."
$plainPwd = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($SaPwd))
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=$plainPwd" -p 1433:1433 --name $InstanceName --hostname $InstanceName -d $ContainerName

Write-Output "Creating new database $DatabaseName on $InstanceName"
docker exec -it $InstanceName /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$plainPwd" -Q "CREATE DATABASE $DatabaseName"
Write-Output "Database $DatabaseName created successfully on $InstanceName."

if ($PathToSqlScript) {
    if (Test-Path $PathToSqlScript) {
        Write-Output "SQL script found at $PathToSqlScript. Executing in container $InstanceName..."
        docker exec -i $InstanceName /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$plainPwd" -i "$PathToSqlScript"
        if ($LASTEXITCODE -eq 0) {
            Write-Output "SQL script executed successfully in container $InstanceName."
        } else {
            Write-Output "SQL script execution failed in container $InstanceName."
        }
    } else {
        Write-Output "SQL script file $PathToSqlScript does not exist."
    }
}
$containerIp = docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $InstanceName
Write-Output "Container $InstanceName IP: $containerIp"
$connectionString = "Server=$containerIp;Database=$DatabaseName;User Id=sa;Password=$plainPwd;"
Set-EnvironmentVariable -Name "$($DatabaseName)_ConnectionString" -Value $connectionString
Write-Output "Connection string for $DatabaseName stored in environment variable $($DatabaseName)_ConnectionString and copied to clipboard."
Write-Output $connectionString | Set-Clipboard
Stop-Transcript