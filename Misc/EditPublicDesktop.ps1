$folderPath = "C:\Users\Public\Desktop"
$acl = Get-Acl $folderPath
$user = New-Object System.Security.Principal.SecurityIdentifier('S-1-5-11')
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule ($user, "Modify", "ContainerInherit,ObjectInherit", "None", "Allow")
$acl.SetAccessRule($rule)
try {
    Set-Acl $folderPath $acl
    Write-Host "Set ACL for Public Desktop to allow Authenticated Users to Modify"
}
catch {
    Write-Host "Failed to set ACL`n"
    Write-Host "$_`n"
}