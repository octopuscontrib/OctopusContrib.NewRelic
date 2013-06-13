function XmlPeek {
     param
     (
          [string] $FilePath,
          [string] $XPath
     )
    [xml] $xml = Get-Content $FilePath -Encoding UTF8
    return $xml.SelectSingleNode($XPath).Value
}
 

function CheckError {
     param (
          [Parameter(Position=0, Mandatory=$true)]
          [string]$message
     )
     if ($lastExitCode -ne 0) {
        throw "$message"
    }
}
 
 
$NugetExe = Resolve-Path ".\nuget.exe"
New-Item .\output -type directory -Force
$OutputPath = Resolve-Path '.\output'
Remove-Item "$OutputPath\*.*" -force
$NuSpecFile = Resolve-Path ".\Generic.NewRelic.nuspec"
if(Select-String -Simple "<id>Specify</id>" $NuSpecFile)
{
	Write-Error "Please specify your own package id in $NuSpecFile"
	exit 1
}

& $NugetExe pack Generic.NewRelic.nuspec -NoPackageAnalysis -OutputDirectory $OutputPath
CheckError "Failed to create Octopus Release Candidate"
$push = Read-Host 'Do you want to push to NuGet feed? (y/n)'
if($push -eq 'y') {
	$url = Read-Host 'Input NuGet feed url'
	$apiKey = Read-Host 'Input the API key for $url'
	Get-childitem -path $OutputPath -Include "*.nupkg" -Recurse | Foreach ($_){ 
		Write-Host "Pushing $_"
		& $NugetExe push $_ $apiKey -source $url
		CheckError "Failed to push $_"
	}
}