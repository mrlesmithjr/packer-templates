function removeApp {
  Param ([string]$appName)
  Write-Output "Trying to remove $appName"
  Get-AppxPackage $appName -AllUsers | Remove-AppxPackage
  Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like $appName | Remove-AppxProvisionedPackage -Online
}

$applicationList = @(
  "Microsoft.BingFinance"
  "Microsoft.3DBuilder"
  "Microsoft.BingFinance"
  "Microsoft.BingNews"
  "Microsoft.BingSports"
  "Microsoft.BingWeather"
  "Microsoft.CommsPhone"
  "Microsoft.Getstarted"
  "Microsoft.WindowsMaps"
  "*MarchofEmpires*"
  "Microsoft.GetHelp"
  "Microsoft.Messaging"
  "*Minecraft*"
  "Microsoft.MicrosoftOfficeHub"
  "Microsoft.OneConnect"
  "Microsoft.WindowsPhone"
  "Microsoft.SkypeApp"
  "Microsoft.WindowsSoundRecorder"
  "*Solitaire*"
  "Microsoft.MicrosoftStickyNotes"
  "Microsoft.Office.Sway"
  "Microsoft.XboxApp"
  "Microsoft.XboxIdentityProvider"
  "Microsoft.XboxGamingOverlay"
  "Microsoft.XboxSpeechToTextOverlay"
  "Microsoft.ZuneMusic"
  "Microsoft.ZuneVideo"
  "Microsoft.NetworkSpeedTest"
  "Microsoft.FreshPaint"
  "Microsoft.Print3D"

  #Non-Microsoft
  "*Autodesk*"
  "*BubbleWitch*"
  "king.com.CandyCrush*"
  "*Dell*"
  "*Dropbox*"
  "*Facebook*"
  "*Keeper*"
  "*Netflix*"
  "*Twitter*"
  "*Plex*"
  "*.Duolingo-LearnLanguagesforFree"
  "*.EclipseManager"
  "ActiproSoftwareLLC.562882FEEB491" # Code Writer
  "*.AdobePhotoshopExpress"
  "A278AB0D.DisneyMagicKingdoms"
  "828B5831.HiddenCityMysteryofShadows"
);

foreach ($app in $applicationList) {
  removeApp $app
}

refreshenv