Invoke-WebRequest -Uri @CaptureClientURL@ -Outfile $env:TEMP\SonicWallCaptureClient.msi
Start-Process msiexec.exe -ArgumentList "/i $env:TEMP\SonicWallCaptureClient.msi  tenantToken=@TenantToken@ /qn"
