OctopusContrib.NewRelic
=======================
OctopusContrib.NewRelic is a package for creating an Octopus Deploy release candidate for installing New Relic. The package can install the New Relic Server Monitor and the New Relic .NET Agent.

## How to get started:
**Step 1:** Download OctopusContrib.NewRelic

Download the OctopusContrib.NewRelic NuGet package from NuGet.Org or download directly from github. 

**Step 2:** Alter NuSpec

Alter the NuSpec file and give it an ID that matches your application. You can have a single package for all your Octopus projects, a more secure approach is to let each project generate their own New Relic package, hence avoiding unwanted installations

**Step 3:** Create Octopus Variables

The installation script (deploy.ps1) supports a number of variables:
- NewRelicAgentApiKey: Mandatory. The New Relic API key
- NewRelicApplicationName: Optional. By convention the installation script will concat the Octopus project name and the Environment. E.g. 'MyApp Staging". If NewRelicApplicationName is set, this will be used instead. Note that this name will be configured in the newrelic.xml configuration file. If you host more than 1 application on the IIS, then add the AppSetting NewRelic.AppName with your application name. For more information se the New Relic documentation https://newrelic.com/docs/dotnet/AgentDocumentation.
- NewRelicIisReset: Optional. If set to 'true' the package will perform an IIS reset after installing New Relic. Note this is required, to let New Relic hook into the IIS. If not specified, an IIS reset will not be performed.

**Step 4:** Replace installers

Optionally replace the New Relic Server Monitor and Agent installer with the newest version.

**Step 5:** Create Octopus Release Candidate

Invoke CreateOctopusPackage.ps1 (or just use NuGet.exe) to create the Octopus Release Candidate. This script will optionally let you upload to your Octopus Release Candidate NuGet repository
