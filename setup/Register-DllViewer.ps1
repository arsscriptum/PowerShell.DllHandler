


<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


[CmdletBinding(SupportsShouldProcess)]
param()


<#
    .SYNOPSIS
        Install-DllViewer64 
    .DESCRIPTION
        Install the DllViewer64 Program Locally

        The installation is done automatically if the file is not locacted on the computer. It is very fast. 

        1. Downloads the ```https://www.nirsoft.net/utils/dllexp-x64.zip``` packages from nirsoft.
        2. Unpack the files to ToolsRoot folder
        3. Set the Environment value DllViewerPath to the installed exe path

#>
function Install-DllViewer64 { 
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$False)]
        [string]$DestinationPath
    )
    begin{
        if([string]::IsNullOrEmpty($DestinationPath)){
            $DestinationPath = "{0}\psloggedon" -f "$PSScriptRoot"
        }
        if(-not(Test-Path -Path "$DestinationPath" -PathType Leaf)){ 
            $Null = New-Item -Path "$DestinationPath" -ItemType Directory -Force -ErrorAction Ignore
        }
        
    }
    process{
      try{
        $Url = "https://www.nirsoft.net/utils/dllexp-x64.zip"
        $TmpPath = "$ENV:Temp\{0}" -f ((Get-Date -UFormat %s) -as [string])
        Write-Verbose "Creating Temporary path `"$TmpPath`"" 
        $Null = New-Item -Path "$TmpPath" -ItemType Directory -Force -ErrorAction Ignore
        $DownloadedFilePath = "{0}\dllexp-x64.zip" -f $TmpPath

        Write-Verbose "Saving `"$Url`" `"$DownloadedFilePath`" ... " 
        $ppref = $ProgressPreference
        $ProgressPreference = 'SilentlyContinue'
        $Results = Invoke-WebRequest -Uri $Url -OutFile $DownloadedFilePath -PassThru
        $ProgressPreference = $ppref 
        if($($Results.StatusCode) -ne 200) {  throw "Error while fetching package $Url" }

        Write-Verbose "Extracting `"$DownloadedFilePath`" ... " 
        
        $InstallPath = "$ENV:ToolsRoot\DllViewer64"
        $Null = New-Item -Path "$InstallPath" -ItemType Directory -Force -ErrorAction Ignore


        $Files = Expand-Archive -Path $DownloadedFilePath -DestinationPath $InstallPath -Force -Passthru
        
        $InstalledExePath = "{0}\dllexp.exe" -f $InstallPath
        if(-not(Test-Path -Path "$InstalledExePath" -PathType Leaf)){ throw "install error" }
        $r = Set-EnvironmentVariable -Name "DllViewerPath" -Value "$InstalledExePath" -Scope User
        $InstalledExePath
      }catch{
        throw $_
      }
    }
}



<#
    .SYNOPSIS
        Search-DllViewer64
    .DESCRIPTION
        Search-DllViewer64

        1. Look in Path (Get-Command)
        2. Look in current folder
        3. Look in ProgramFiles and TEMP folders
#>
function Search-DllViewer64 { 
    [CmdletBinding(SupportsShouldProcess)]
    param()

    begin{
        
        [string]$CurrentPath = "$PSScriptRoot"
        $SearchLocations = @("$CurrentPath", "$ENV:Temp", "$ENV:ToolsRoot")

    }
    process{
      try{
        $DllViewer64Exe = ""
        if([string]::IsNullOrEmpty("$ENV:DllViewerPath") -eq $False){
            if((Test-Path -Path "$ENV:DllViewerPath" -PathType Leaf)){
                $DllViewer64Exe = "$ENV:DllViewerPath"
                Write-Verbose "Found `"$DllViewer64Exe`" in ENV:DllViewerPath"
                return "$DllViewer64Exe"
            }
        }
        
        $Cmd = Get-Command "dllexp.exe"
        if($Cmd -ne $Null){
            $DllViewer64Exe = $Cmd.Source
            Write-Verbose "Found `"$DllViewer64Exe`" in PATH"
        }else{
            [string[]]$SearchResults = ForEach($dir in $SearchLocations){
                Write-Verbose "Searching in `"$dir`""
                Get-ChildItem -Path "$dir" -File -Recurse -Filter "dllexp.exe" -Depth 2 -ErrorAction Ignore | Select -ExpandProperty Fullname
            }
            $SearchResultsCount = $SearchResults.Count
            if($SearchResultsCount -gt 0){
                $DllViewer64Exe = $SearchResults[0]
                Write-Verbose "Found $SearchResultsCount Results. Using `"$DllViewer64Exe`""
            }
        }
        
        return "$DllViewer64Exe"
      }catch{
        throw $_
      }
    }
}


<#
    .SYNOPSIS
        Get-DllExports
    .DESCRIPTION
        Launch Dll Viewer app

#>
function Get-DllExports { 
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position = 0, Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Dll Path")]
        [string]$Path
    )
    begin{

        # Search fot PSLoggedOn program...
        [string]$DllViewer64Exe = Search-DllViewer64
        if([string]::IsNullOrEmpty($DllViewer64Exe)){
            # Install it if no existant
            Write-Verbose "Canot find DllViewer64Exe, Installing DllViewer64Exe"
            $DllViewer64Exe = Install-DllViewer64
            Write-Verbose "Using `"$DllViewer64Exe`""
        }
        if(-not(Test-Path -Path "$DllViewer64Exe" -PathType Leaf)){ 
            throw "cannot find DllViewer64Exe"
        }
    }
    process{
      try{
        # Execute the program and parse the output
        &"$DllViewer64Exe" "$Path" 
        
      }catch{
        throw $_
      }
    }
}



<#
    .SYNOPSIS
        Get-DllExports
    .DESCRIPTION
        Launch Dll Viewer app

#>
function Register-DllViewInContextMenu { 
    [CmdletBinding(SupportsShouldProcess)]
    param()
    begin{

        # Search fot PSLoggedOn program...
        [string]$DllViewer64Exe = Search-DllViewer64
        if([string]::IsNullOrEmpty($DllViewer64Exe)){
            # Install it if no existant
            Write-Verbose "Canot find DllViewer64Exe, Installing DllViewer64Exe"
            $DllViewer64Exe = Install-DllViewer64
            Write-Verbose "Using `"$DllViewer64Exe`""
        }
        if(-not(Test-Path -Path "$DllViewer64Exe" -PathType Leaf)){ 
            throw "cannot find DllViewer64Exe"
        }
    }
    process{
      try{
        
        
      }catch{
        throw $_
      }
    }
}

