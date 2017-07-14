Set-StrictMode -Version 'latest'
$errorActionPreference = 'Stop'


function Get-LastUriSegment
{
  param (
    [Parameter(Mandatory=$true,Position=1)]
    [Uri] $Uri
  )
    
  if ($Uri.Segments.Count -lt 1)
  {
    throw "Invalid URL: $url"
  }

  return $Uri.Segments[-1]
}
function Get-Download {
  param(
    [Parameter(Mandatory=$true,Position=1)]
    [Uri] $Uri
  )

  $downloadLocation = Join-Path ([System.IO.Path]::GetTempPath()) (Get-LastUriSegment $Uri)
    
  if (Test-Path $downloadLocation) {
    Remove-Item -Force $downloadLocation
  }
    
  Invoke-WebRequest -Uri $Uri -OutFile $downloadLocation

  return $downloadLocation
}

function Wait-Process{
  param (
    [Parameter(Mandatory=$true,Position=1)]
    [System.Diagnostics.Process] $Process
  )

}

function Install-Download {
  param (
    [Parameter(Mandatory=$true,Position=1)]
    [Uri] $Uri
  )

  $downloadLocation = Get-Download $Uri

  Write-Verbose "Installing $downloadLocation..."

  $process = [System.Diagnostics.Process]::Start($downloadLocation, "/quiet /norestart ")
  
    if (-not $process.WaitForExit(10 * 60 * 1000))
    {
        throw "Installing $($Process.Name) timed out"
    }

   $returnCode = $Process.ExitCode

   Write-Verbose "Install return code: $returnCode"

   return $returnCode
}

function Install-PowerShellCore
{
    [CmdletBinding()]
    param ()

    #
    # PS Core installers:
    #   * https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-beta.4/PowerShell-6.0.0-beta.4-win10-win2016-x64.msi
    #   * https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-beta.4/PowerShell-6.0.0-beta.4-win81-win2012r2-x64.zip
    # The standard Appveyor image is a Windows Server 2012 R2, which is installed below
    #
    Install-Download 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-beta.4/PowerShell-6.0.0-beta.4-win81-win2012r2-x64.zip'
}

Export-ModuleMember -Function Install-PowerShellCore
