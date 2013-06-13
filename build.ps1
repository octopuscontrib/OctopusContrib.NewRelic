$NugetExe = Resolve-Path ".\package\nuget.exe"
$PackagePath = Resolve-Path ".\package"

& $NugetExe pack OctopusContrib.NewRelic.nuspec -basepath $PackagePath -NoDefaultExcludes -NoPackageAnalysis