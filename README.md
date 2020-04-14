# CheckForNewNodeJS.ps1

## What does this script do?

This Powershell script tests the installed Node.js version and checks if there is a newer Windows installation package available.

The script will raise a "balloon" notification window if it detects a newer version.

If the user clicks on the notification window, the script will open the Node.js download site in the default browser.

## How to install the scheduled task

To invoke the script periodically in the background you can call it with the switch "-InstallTask". This will install a Powershell scheduled task named "CheckForNewNodeJSVersion" which will be invoked every Monday, 10 AM. In order to be able to install scheduled tasks you have to invoke the script in an administrative PowerShell console. Otherwise the script will fail with an access denied error.
```
.\CheckForNewNodeJS.ps1 -InstallTask
```
