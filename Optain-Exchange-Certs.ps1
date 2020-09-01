param (
	[Parameter(Mandatory)]
    [string]$uri,
	[Parameter(Mandatory)]
	[string]$destination,
	
	[Parameter(Mandatory)]
	[String]$Domain,
	[Parameter(Mandatory)]
    [string]$SubscriptionID,
	[Parameter(Mandatory)]
	[string]$TenantId,
	[Parameter(Mandatory)]
    [string]$AppID,
	[Parameter(Mandatory)]
    [string]$AZAppPass
)

function Get-LECertificates {
	
	[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
	New-Item -Path C:\Temp -ItemType Directory -Force
	Install-PackageProvider -Name NuGet -Force
	Install-Module -Name Posh-ACME -Force -Scope AllUsers

	$azParams = @{
		AZSubscriptionId = $SubscriptionID
		AZTenantId = $TenantId
		AZAppUsername = $AppID
		AZAppPasswordInsecure = $AZAppPass
	}

	New-PACertificate "*.$Domain","$Domain" -AcceptTOS -DnsPlugin Azure -PluginArgs $azParams -Verbose > C:\Temp\acme.log

	New-Item -Path C:\Certificates -ItemType Directory -Force 
	$Path = (Get-PACertificate).CertFile  
	$Path = $Path.Substring(0,$Path.Length - 9) 
	$Path = "$Path\*.*" 
	Copy-Item -Path $Path -Destination C:\Certificates -Recurse 

	
}

function DownloadISO {

	# Local file storage location
    $localPath = "$env:SystemDrive"

    # Log file
    $logFileName = "CSDownload.log"
    $logFilePath = "$localPath\$logFileName"
	
	if(Test-Path $destination) {
		"Destination path exists. Skipping ISO download" | Tee-Object -FilePath $logFilePath -Append
		return
	}
	
	$destination = Join-Path $env:SystemDrive $destination
	New-Item -Path $destination -ItemType Directory

	$destinationFile = $null
    $result = $false
	# Download ISO
	$retries = 3
	# Stop retrying after download succeeds or all retries attempted
	while(($retries -gt 0) -and ($result -eq $false)) {
		try
		{
			"Downloading ISO from URI: $uri to destination: $destination" | Tee-Object -FilePath $logFilePath -Append
			$isoFileName = [System.IO.Path]::GetFileName($uri)
			$webClient = New-Object System.Net.WebClient
			$_date = Get-Date -Format hh:mmtt
			$destinationFile = "$destination\$isoFileName"
			$webClient.DownloadFile($uri, $destinationFile)
			$_date = Get-Date -Format hh:mmtt
			if((Test-Path $destinationFile) -eq $true) {
				"Downloading ISO file succeeded at $_date" | Tee-Object -FilePath $logFilePath -Append
				$result = $true
			}
			else {
				"Downloading ISO file failed at $_date" | Tee-Object -FilePath $logFilePath -Append
				$result = $false
			}
		} catch [Exception] {
			"Failed to download ISO. Exception: $_" | Tee-Object -FilePath $logFilePath -Append
			$retries--
			if($retries -eq 0) {
				Remove-Item $destination -Force -Confirm:0 -ErrorAction SilentlyContinue
			}
		}
	}
	
	# Extract ISO
	if($result)
    {
        "Mount the image from $destinationFile" | Tee-Object -FilePath $logFilePath -Append
        $image = Mount-DiskImage -ImagePath $destinationFile -PassThru
        $driveLetter = ($image | Get-Volume).DriveLetter

        "Copy files to destination directory: $destination" | Tee-Object -FilePath $logFilePath -Append
        Robocopy.exe ("{0}:" -f $driveLetter) $destination /E | Out-Null
    
        "Dismount the image from $destinationFile" | Tee-Object -FilePath $logFilePath -Append
        Dismount-DiskImage -ImagePath $destinationFile
    
        "Delete the temp file: $destinationFile" | Tee-Object -FilePath $logFilePath -Append
        Remove-Item -Path $destinationFile -Force
    }
    else
    {
		"Failed to download the file after exhaust retry limit" | Tee-Object -FilePath $logFilePath -Append
		Remove-Item $destination -Force -Confirm:0 -ErrorAction SilentlyContinue
        Throw "Failed to download the file after exhaust retry limit"
    }
}

Get-LECertificates

DownloadISO

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
 iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
 sleep 10
 choco install "netfx-4.8" -y
 choco install vscode -y
 choco install microsoft-edge -y
 
 
 
$LanguageSetting = "de-DE"
$GeoIDSetting = "94"
$TimeZoneSetting = "W. Europe Standard Time"
$regionalsettingsURL = "https://raw.githubusercontent.com/sredlin/Azure/master/AzureVMRegionalSettings/Settings/AzureVMLanguageDE.xml"
$RegionalSettings = "D:\AzureVMLanguageDE.xml"
       
#downdload regional settings file
Invoke-WebRequest $regionalsettingsURL -OutFile $RegionalSettings

        
# Set Locale, language etc. 
& $env:SystemRoot\System32\control.exe "intl.cpl,,/f:`"$RegionalSettings`""

# Set languages/culture. Not needed perse.
Set-WinSystemLocale $LanguageSetting
Set-WinUserLanguageList -LanguageList $LanguageSetting -Force
Set-Culture -CultureInfo $LanguageSetting
Set-WinHomeLocation -GeoId $GeoIDSetting
Set-TimeZone -Name $TimeZoneSetting
