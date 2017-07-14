Set-StrictMode -Version 'latest'
$errorActionPreference = 'Stop'


function Get-Download {
  param(
    [Parameter(Mandatory=$true,Position=1)]
    [Uri] $Uri
  )

  if ($Uri.Segments.Count -lt 1)
  {
    throw "Invalid URL: $url"
  }

  $fileName = $Uri.Segments[-1]

  $downloadLocation = Join-Path ([System.IO.Path]::GetTempPath()) $fileName
    
  if (Test-Path $downloadLocation) {
    Remove-Item -Force $downloadLocation
  }
    
  Invoke-WebRequest -Uri $Uri -OutFile $downloadLocation

  return $downloadLocation
}

function Invoke-Installer {
  param (
    [Parameter(Mandatory=$true,Position=1)]
    [string] $Installer
  )

  $process = [System.Diagnostics.Process]::Start($Installer, "/quiet /norestart ")
  
    if (-not $process.WaitForExit(10 * 60 * 1000))
    {
        throw "Timeout installing $Installer"
    }

   $returnCode = $Process.ExitCode

   return $returnCode
}

function Install-PowerShellCore
{
    [CmdletBinding()]
    param ()
    #
    # PS Core installers:
    #   * https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-beta.4/PowerShell-6.0.0-beta.4-win10-win2016-x64.msi
    #   * https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-beta.4/PowerShell-6.0.0-beta.4-win81-win2012r2-x64.msi
    #
    # The standard Appveyor image is a Windows Server 2012 R2, which is installed below
    #
    $installer = Get-Download 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-beta.4/PowerShell-6.0.0-beta.4-win81-win2012r2-x64.msi'

    Invoke-Installer $installer
}

Export-ModuleMember -Function Install-PowerShellCore
