# CheckForNewNodeJS.ps1

## What does this script do?

This Powershell script tests the installed Node.js version and checks if there is a newer Windows installation package available.

The script will raise a "balloon" notification window if it detects a newer version.

If the user clicks on the notification window, the script will open the Node.js download site in the default browser.

The script also provides a function "InstallJob" which registers a Powershell scheduled task to invoke the script periodically (default is Monday every week, 10 PM).

## How to install the scheduled task

Open a Powershell window an "source" the powershell script using the following command:
```
. .\CheckForNewNodeJS.ps1
```
Now you can invoke the "InstallJob" function:
```
InstallJob
```
