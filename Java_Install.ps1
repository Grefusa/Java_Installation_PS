#Desired version to install as reference
[version]$refVersion = '8.0.2210.11'
function install-java
{
    #Prepare work folder.

    $workdir = "c:\Source"

    if (Test-Path -Path $workdir -PathType Container)
    { Write-host "$workdir already exists" -ForegroundColor Yellow}
    else
    { New-Item -Path $workdir -ItemType directory}

    #Download the installer

    $source = "URL FOR JAVA INSTALLER"
    $destination = "$workdir\jre.exe"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest $source -OutFile $destination

    #Install Java
    Write-Host "Installing Java..." -ForegroundColor Yellow
    Start-Process -FilePath "$workdir\jre.exe" -ArgumentList "/s REMOVEOUTOFDATEJRES=1"

    Start-Sleep -s 35

    $newobject = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -Match 'Java 8'}

    Write-Host "Java has been upgraded to: " $newobject.DisplayVersion -ForegroundColor Green
}
function remove-java
{
    #In case we are installing an order version, we uninstall first java from the computer.
    Write-host "Uninstalling java..." -ForegroundColor Yellow
    $oldJava = $object.PSChildName
    msiexec /x $oldJava /qn
    Start-Sleep -s 35

}


if($object = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -Match 'Java 8'})
{
    $object.DisplayName
    $object.DisplayVersion

    [version]$objectVersion = $object.DisplayVersion

    #Check Java version and then upgrade if necessary change to -gt if you want to upgrade to the latest version.
    if($refVersion -ne $objectVersion)
    {
        remove-java
        Write-host "Java was uninstalled, installing the desired version..."
        install-java        
    }
    else
    {
        Write-Host "Java is already on: " $object.DisplayVersion -ForegroundColor Green
    }
}
else
{ 
    #in case that Java is not installed, it will install it.
    Write-Host "No Java detected, installing..." -ForegroundColor Cyan 
    install-java
}