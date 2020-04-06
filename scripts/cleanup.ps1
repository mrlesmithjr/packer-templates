Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase
Optimize-Volume -DriveLetter C
sdelete -q -z c:
