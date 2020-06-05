Param(
    [switch]$InstallTask,
	[switch]$DeleteTask
)

function ShowBalloonTip($tipText, $tipTitle, $clickURL, $tipDuration = 5000) {
    Add-Type -AssemblyName  System.Windows.Forms
    if ($global:balloon) {
        DisposeBalloonTip
    }
    $global:balloon = New-Object System.Windows.Forms.NotifyIcon 
    [void](Register-ObjectEvent  -InputObject $balloon  -EventName BalloonTipClicked  -SourceIdentifier TipClicked -MessageData "$clickURL" -Action {
        Start-Process -FilePath $Event.MessageData
        DisposeBalloonTip
    }) 
    [void](Register-ObjectEvent  -InputObject $balloon  -EventName BalloonTipClosed  -SourceIdentifier TipClosed  -Action {
        DisposeBalloonTip
    }) 
    $path = (Get-Process -id $pid).Path
    $balloon.Icon  = [System.Drawing.Icon]::ExtractAssociatedIcon($path) 
    $balloon.BalloonTipIcon  = [System.Windows.Forms.ToolTipIcon]::Info
    $balloon.BalloonTipText  = $tipText
    $balloon.BalloonTipTitle  = $tipTitle
    $balloon.Visible  = $true 
    $balloon.ShowBalloonTip($tipDuration)
}

function DisposeBalloonTip() {
    $global:balloon.dispose()
    Unregister-Event  -SourceIdentifier TipClicked
    Unregister-Event  -SourceIdentifier TipClosed
    Remove-Job -Name TipClicked
    Remove-Job -Name TipClosed
    Remove-Variable  -Name balloon -Scope Global
}

function InstallScheduledJob() {
   $T = New-JobTrigger -Weekly -At "10:00 PM" -DaysOfWeek Monday -WeeksInterval 1
   Register-ScheduledJob -Name "CheckForNewNodeJSVersion" -FilePath $PSCommandPath -Trigger $T
}

function DeleteScheduledJob() {
   Unregister-ScheduledJob -Name "CheckForNewNodeJSVersion"
}

if ($InstallTask) {
    InstallScheduledJob
    exit
}

if ($DeleteTask) {
	DeleteScheduledJob
	exit
}

$matchInfo = (& node -v) | Select-String -Pattern ".*((v\d+)\.\d+\.\d+).*"
if ($matchInfo.Matches.Success) {
   $version = $matchInfo.Matches.Groups[1].Value
   $nodeMajorVersion = $matchInfo.Matches.Groups[2].Value
   Write-Host "Installed Node.js version: $version"
} else {
   $version = ""
   $nodeMajorVersion = ""
}

$nodeJSURL = "https://nodejs.org/dist/latest-$nodeMajorVersion.x/"
Write-Host "Retrieving file list from $nodeJSURL"
$response = Invoke-WebRequest -Uri $nodeJSURL
if ($response.StatusCode -eq 200) {
    $newVersion = ""
    if ($version) {
        foreach ($link in $response.Links) {
            $matchInfo = $link.innerText | Select-String -Pattern "node-((v\d+)\.\d+\.\d+)-x64\.msi"
            if ($matchInfo.Matches.Success) {
                $newVersion = $matchInfo.Matches.Groups[1].Value
                break
            }
        }
        
        Write-Host "Latest version: $newVersion"

        if ($newVersion -and ($newVersion -ne $version)) {
            ShowBalloonTip -tipText "Installed: $version, Remote: $newVersion" -tipTitle "New NodeJS version available" -clickURL "$nodeJSURL"
        }
    }
}



