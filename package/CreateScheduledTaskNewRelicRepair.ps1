$repairFile = "C:\Program Files\New Relic\RepairNewRelic.ps1"

if (Test-Path ($repairFile)) {
   Remove-Item $repairFile -Force

}

New-Item $repairFile -type file -Force


Add-Content $repairFile "`$HKLM = 2147483650 #HKEY_LOCAL_MACHINE`n"
Add-Content $repairFile "`$reg = [wmiclass]'\\.\root\default:StdRegprov'`n"

Add-Content $repairFile "`$key = 'SYSTEM\CurrentControlSet\Services\W3SVC'`n"
Add-Content $repairFile "`$name = 'Environment'`n"
Add-Content $repairFile "`$value = 'COR_ENABLE_PROFILING=1','COR_PROFILER={71DA0A04-7777-4EC6-9643-7D28B46A8A41}','NEWRELIC_INSTALL_PATH=C:\Program Files\New Relic\.NET Agent\'`n"
Add-Content $repairFile "`$reg.SetMultiStringValue(`$HKLM, `$key, `$name, `$value)`n"

Add-Content $repairFile "`$key = 'SYSTEM\CurrentControlSet\Services\WAS'`n"
Add-Content $repairFile "`$name = 'Environment'`n"
Add-Content $repairFile "`$value = 'COR_ENABLE_PROFILING=1','COR_PROFILER={71DA0A04-7777-4EC6-9643-7D28B46A8A41}','NEWRELIC_INSTALL_PATH=C:\Program Files\New Relic\.NET Agent\'`n"
Add-Content $repairFile "`$reg.SetMultiStringValue(`$HKLM, `$key, `$name, `$value)`n"

Add-Content $repairFile "iisreset `n" 


schtasks /Create /SC ONSTART /RU System  /EC Security /TN "Repair New Relic COR_PROFILER values" /TR "powershell -NoProfile -ExecutionPolicy unrestricted -file '$repairFile' " /F
