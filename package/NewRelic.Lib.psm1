                    $NewRelicAgentNameFilter32Bit = "NewRelicAgent*x86*.msi"
                    $NewRelicAgentNameFilter64Bit = "NewRelicAgent*x64*.msi"
                    $NewRelicServerMonitorNameFilter64Bit = "NewRelicServerMonitor*x64*"
                    $NewRelicServerMonitorNameFilter32Bit = "NewRelicServerMonitor*x86*"

                    $UseLocalInstallationFiles = $true;
                    $msiExec = "msiexec.exe"
                    $CurentDir = Resolve-Path .\

                function Is64Bit {
                    Write-Host "Determining bits"
                    $result = Get-WmiObject -Class Win32_Processor | Select-Object AddressWidth

                    if ( $result.AddressWidth -eq 32)
                    {
                        return $false
                    }

                    return $true
                }

                function SearchForFile {
                    param([string]$filename)
                    Write-Host $CurrentDir
                    $file =  Get-ChildItem -Path .\ -Filter $filename -Recurse | ForEach-Object -Process {$_.FullName} 
                    return $file
                }

                function Install-MSIFile {
                     Param(
                      [parameter(mandatory=$true,ValueFromPipeline=$true,ValueFromPipelinebyPropertyName=$true)]
                            [ValidateNotNullorEmpty()]
                            [string]$msiFile,

                            [parameter()]
                            [ValidateNotNullorEmpty()]
                            [string]$arguments
                     )
                    if (!(Test-Path $msiFile)){
                        throw "Path to the MSI File $($msiFile) is invalid. Please supply a valid MSI file"
                    }

                    Write-Verbose "Installing $msiFile....."
                    $arg = [string]::Format( "/i {0} /qn {1}", $msiFile, $arguments) 
                    Write-Host $arg
                    $process = Start-Process -FilePath msiexec.exe -ArgumentList $arg -Wait -PassThru

                    if ($process.ExitCode -eq 0){
                        Write-Verbose "$msiFile has been successfully installed"
                    }
                    else {
                        Write-Verbose "installer exit code  $($process.ExitCode) for file  $($msifile)"
                    }
                }

                 function DownloadFile($url, $filename)  
                 {  
                   $wc = New-Object System.Net.WebClient  
                   Register-ObjectEvent -InputObject $wc -EventName DownloadProgressChanged -SourceIdentifier WebClient.DownloadProgressChanged -Action { Write-Progress -Activity "Downloading: $($EventArgs.ProgressPercentage)% Completed" -Status $url -PercentComplete $EventArgs.ProgressPercentage; }    
                   Register-ObjectEvent -InputObject $wc -EventName DownloadFileCompleted -SourceIdentifier WebClient.DownloadFileComplete -Action { Write-Host "Download Complete - $filename"; Unregister-Event -SourceIdentifier WebClient.DownloadProgressChanged; Unregister-Event -SourceIdentifier WebClient.DownloadFileComplete; }  
                   try  
                   {  
                     $wc.DownloadFileAsync($url, $filename)  
                   }  
                   catch [System.Net.WebException]  
                   {  
                     Write-Host("Cannot download $url")  
                   }   
                   finally  
                   {    
                     $wc.Dispose()  
                   }  
                 }  

                function DownloadNewRelicAgent {
                    $storageDir = $CurrentDir + "\\temp"
                    $webclient = New-Object System.Net.WebClient
                    $url = $NewRelicAgentInstallationUrl64Bit
                    $file = "$storageDir\agent.msi"
                    $webclient.DownloadFile($url,$file)
                }

                function InstallNewRelicAgent { 
                     param (
                          [Parameter(Position=0, Mandatory=$true)]
                          [string]$licenseKey,
                          [Parameter(Position=1, Mandatory=$true)]
                          [string]$applicationName
                     )
                    $agentInstaller = $null
                    $agentConfiguration = $null
                    if($UseLocalInstallationFiles) {
                        if(Is64Bit) {
                            $agentInstaller = SearchForFile $NewRelicAgentNameFilter64Bit
                        }
                        else {
                            $agentInstaller = SearchForFile $NewRelicAgentNameFilter32Bit
                        }       
                    }
                    if(!$agentInstaller)
                    {
                        Write-Error "Cannot find intallation package"
                        return 1;
                    }
                    Write-Host "Found $agentInstaller"
                    # ADDLOCAL=ProgramsFeature,AllAppsEnvironmentFeature,IISRegistryFeature,ToolsShortcutFeature
                    $arguments = "/le .\NewRelicAgentInstall.log NR_LICENSE_KEY=$licenseKey INSTALLLEVEL=1"
                    Write-Host "Installation log:"
                    Install-MSIFile $agentInstaller $arguments
                    Get-Content "NewRelicAgentInstall.log" | Write-Host
                    $agentConfiguration = "$env:ALLUSERSPROFILE\New Relic\.NET Agent\newrelic.config"
                    Write-Host "Configuring New Relic default application name to $applicationName"
                    (Get-Content $agentConfiguration) | 
                    Foreach-Object { $_ -replace "<name>.*</name>", "<name>$applicationName</name>"} | 
                    Set-Content $agentConfiguration


                }



                function InstallNewRelicServerMonitor {
                     param (
                          [Parameter(Position=0, Mandatory=$true)]
                          [string]$licenseKey
                     )
                    $serverMonitorInstaller = $null
                    if($UseLocalInstallationFiles) {
                        if(Is64Bit) {
                            $serverMonitorInstaller = SearchForFile $NewRelicServerMonitorNameFilter64Bit
                        }
                        else {
                            $serverMonitorInstaller = SearchForFile $NewRelicServerMonitorNameFilter32Bit
                        }
                        
                        if(!$serverMonitorInstaller) {
                            Write-Host "Cannot find New Relic Server Monitor installation package"
                            exit 1
                        }
                    }
                    
                    Write-Host "Found $serverMonitorInstaller"  
                    $arguments = "/le .\NewRelicServerMonitorInstall.log NR_LICENSE_KEY=$licenseKey"
                    Write-Host "Installation log:"
                    Install-MSIFile $serverMonitorInstaller $arguments
                    Get-Content ".\NewRelicServerMonitorInstall.log" | Write-Host
                }