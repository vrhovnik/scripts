# Containers Scripts

PowerShell scripts for working with Docker containers and SQL Server in containers.

## Prerequisites

- [PowerShell 7+](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) or Docker Engine

## Scripts

### `New-Database.ps1`

Alias: `cndb`

Creates a SQL Server database inside a new Docker container. Generates a random container name if none is provided, validates the SA password against SQL Server policy, and stores the connection string in a user environment variable.

```powershell
# Create a database with default settings (port 1433)
New-Database.ps1 -DatabaseName "MyDb" -SaPwd "MySecure@Pwd1"

# Custom port
New-Database.ps1 -DatabaseName "MyDb" -SaPwd "MySecure@Pwd1" -HostPort 1434

# Named instance, overwrite if exists
New-Database.ps1 -DatabaseName "MyDb" -InstanceName "sql1" -SaPwd "MySecure@Pwd1" -Overwrite

# Execute an initialization SQL script after creation
New-Database.ps1 -DatabaseName "MyDb" -SaPwd "MySecure@Pwd1" -PathToSqlScript "C:\scripts\init.sql"
```

After creation, the connection string is available as an environment variable:

```powershell
$env:MyDb_ConnectionString
# Server=127.0.0.1,1433;Database=MyDb;User Id=sa;Password=<pwd>;
```

#### SQL Server Password Policy

The SA password must:
- Be between 8 and 128 characters
- Contain characters from at least **three** of the following four categories:
  - Uppercase letters (A–Z)
  - Lowercase letters (a–z)
  - Digits (0–9)
  - Symbols (`!`, `@`, `#`, `$`, etc.)

📖 [SQL Server Password Policy](https://learn.microsoft.com/en-us/sql/relational-databases/security/password-policy)

---

## Tests

Tests are in the [`tests/`](tests/) folder and use [Pester](https://pester.dev/).

```powershell
Invoke-Pester -Path ./tests/Containers.Tests.ps1 -Output Detailed
```

Tests include syntax validation, parameter checks, and functional tests for the SQL password policy function. The password policy tests run without requiring Docker.

## Additional Resources

- [SQL Server on Docker](https://learn.microsoft.com/en-us/sql/linux/quickstart-install-connect-docker)
- [Docker documentation](https://docs.docker.com/)
- [SQL Server security documentation](https://learn.microsoft.com/en-us/sql/relational-databases/security/sql-server-security)
