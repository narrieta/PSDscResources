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
    # One of the prerequisites for installing PS Core is the VS2015 C++ redistributable at https://download.my.visualstudio.com/pr/mu_visual_cpp_2015_redistributable_update_3_x64_9052538.exe.
    # This URI requires signing in first, though, so I made a copy to https://narrieta.blob.core.windows.net/dsc/mu_visual_cpp_2015_redistributable_update_3_x64_9052538.exe?sv=2014-02-14&ss=2017-07-06T19%3A39%3A34Z&se=2017-12-31T20%3A39%3A04Z&sp=r&sr=b&sig=MNqxvw%2F9%2FbgMUfKd8RYNK0AKsx0WSKClf%2BcwhX5EGrM%3D
    # The standard Appveyor image already includes this component, so I am skipping it for the moment.
    #
    # As far as PS Core itself, there are different installers for different Windows versions:
    #   * https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-beta.3/PowerShell-6.0.0-beta.3-win10-win2016-x64.msi
    #   * https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-beta.3/PowerShell-6.0.0-beta.3-win81-win2012r2-x64.msi
    # The standard Appveyor image is a Windows Server 2012 R2, which is installed below
    #
    Install-Download 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-beta.3/PowerShell-6.0.0-beta.3-win81-win2012r2-x64.msi'
}

Export-ModuleMember -Function Install-PowerShellCore
