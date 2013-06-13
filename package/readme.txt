See https://github.com/octopuscontrib/OctopusContrib.NewRelic/blob/master/README.md

Alter Generic.NewRelic.nuspec and set ID and version. 
Call CreateOctopusPackage.ps1 to create Octopus Deploy package and optionally push to NuGet feed.

Mandatory Octopus Deploy variables
-NewRelicAgentApiKey: New Relic API key

Optional Octopus Deploy variables
-NewRelicApplicationName: Optional variable to set New Relic Application in the newrelic.xml configuration file
-NewRelicIisReset: Set to true if Octopus Deploy package should do an IIS reset. If not specified, IIS reset will not be performed.