function ShowHeader()
{
    $MainMessage = "Windows Investigator by rootshellace ©"
    $FinalMessage = "#" + $MainMessage.PadLeft(58, " ").PadRight(78, " ") + "#"
    Write-Host -Object ("#" * 80) -ForegroundColor Red
    Write-Host -Object ("#" + " " * 78 + "#") -ForegroundColor Red
    Write-Host -Object $FinalMessage -ForegroundColor Red
    Write-Host -Object ("#" + " " * 78 + "#") -ForegroundColor Red
    Write-Host -Object ("#" * 80) -ForegroundColor Red
}

function ShowSection([string]$Message, [string]$Color)
{
    $BannerLength = 80
    $MsgLength = $Message.Length
    $PadLength = $BannerLength - $MsgLength - 2
    $LPadLength = [int]$($PadLength / 2)
    $FinalMsg = $Message.PadLeft($LPadLength + $MsgLength, ' ').PadRight($BannerLength - 2, ' ')

    Write-Host -Object ('#' * $BannerLength) -ForegroundColor $Color
    Write-Host -Object ('#' + $FinalMsg + '#') -ForegroundColor $Color
    Write-Host -Object ('#' * $BannerLength) -ForegroundColor $Color
}

function CheckCommandExists([string]$Command)
{
    $CmdTestResult = (Get-Command -Name $Command -ErrorAction SilentlyContinue)

    if ($CmdTestResult)
    {
        return 1
    }
    else 
    {
        return 0
    }
}

function PrintTableBorder([Int32]$MaxLengthProperty, [Int32]$MaxLengthValue, [string]$BorderColor)
{
    $LineLength = $MaxLengthProperty + $MaxLengthValue + 7
    $BorderLine = '-' * $LineLength
    Write-Host -Object $BorderLine -ForegroundColor $BorderColor
}

function PrintTableRow([Int32]$MaxLengthProperty, [Int32]$MaxLengthValue, [string]$Property, [string]$Value, [string]$RowColor)
{
    $PropertyLength = $Property.Length
    $ValueLength = $Value.Length
    $TotalPropertyPadLength = $MaxLengthProperty - $PropertyLength
    $TotalValuePadLength = $MaxLengthValue - $ValueLength

    if ($TotalPropertyPadLength % 2 -eq 1)    
    {
        $TotalPropertyLeftPadLength = ($TotalPropertyPadLength - 1) / 2
    }
    else 
    {    
        $TotalPropertyLeftPadLength = $TotalPropertyPadLength / 2
    }

    if ($TotalValuePadLength % 2 -eq 1)    
    {
        $TotalValueLeftPadLength = $(($TotalValuePadLength - 1) / 2)
    }
    else 
    {    
        $TotalValueLeftPadLength = $($TotalValuePadLength / 2)
    }

    $PropertyString = $Property.PadLeft($PropertyLength + $TotalPropertyLeftPadLength, ' ').PadRight($PropertyLength + $TotalPropertyPadLength, ' ')
    $ValueString = $Value.PadLeft($ValueLength + $TotalValueLeftPadLength, ' ').PadRight($ValueLength + $TotalValuePadLength, ' ')
    $ValueLine = '| ' + $PropertyString + ' | ' + $ValueString + ' |'

    Write-Host -Object $ValueLine -ForegroundColor $RowColor    
}

function ShowStepInfo([array]$Msg, [string]$Color)
{
    if ($Msg)
    {
        foreach ($item in $Msg)
        {
            Write-Host -Object $item -ForegroundColor $Color
        }
    }
}

function RetrieveComputerInfo()
{
    try 
    {
        $ComputerInfoCmdTest = CheckCommandExists -Command Get-ComputerInfo
    
        if ($ComputerInfoCmdTest)
        {
            $Msg = @("", "[+] Retrieving computer info...", "")
            ShowStepInfo -Msg $Msg -Color 'Green'
    
            $ComputerInfoData = Get-ComputerInfo
            $PropertyList = @('OsName', 'OsVersion', 'OsBuildNumber', 'OsSystemDrive', 'OsWindowsDirectory', 'OsSystemDirectory', 
                                'OsInstallDate', 'TimeZone', 'OsLocalDateTime', 'OsUptime', 'CsDNSHostname', 'CsDomain',
                                'CsDomainRole', 'CsUserName', 'CsWorkGroup', 'LogonServer')
            $PropertyHT = @{'OsName' = "" ; 'OsVersion' = "" ; 'OsBuildNumber' = "" ; 'OsSystemDrive' = "" ; 'OsWindowsDirectory' = "" ; 
                            'OsSystemDirectory' = "" ; 'OsInstallDate' = "" ; 'TimeZone' = "" ; 'OsLocalDateTime' = "" ; 'OsUptime' = "" ;
                            'CsDNSHostname' = "" ; 'CsDomain' = "" ; 'CsDomainRole' = "" ; 'CsUserName' = "" ; 'CsWorkGroup' = "" ; 
                            'LogonServer' = ""}
    
            foreach ($property in $PropertyList)
            {
                $PropertyHT[$property] = $ComputerInfoData.$property
            }
    
            $MaxKeyLength = ($PropertyHT.Keys | Measure-Object -Maximum -Property Length).Maximum
            $MaxValueLength = ($PropertyHT.Values | Measure-Object -Maximum -Property Length).Maximum
    
            PrintTableBorder -MaxLengthProperty $MaxKeyLength -MaxLengthValue $MaxValueLength -BorderColor 'DarkYellow'
            PrintTableRow -MaxLengthProperty $MaxKeyLength -MaxLengthValue $MaxValueLength -Property 'Property' -Value 'Value' -RowColor 'DarkYellow'
            PrintTableBorder -MaxLengthProperty $MaxKeyLength -MaxLengthValue $MaxValueLength -BorderColor 'DarkYellow'
    
            foreach ($property in $PropertyList)
            {
                PrintTableRow -MaxLengthProperty $MaxKeyLength -MaxLengthValue $MaxValueLength -Property $property -Value $PropertyHT[$property] -RowColor 'Yellow'
                PrintTableBorder -MaxLengthProperty $MaxKeyLength -MaxLengthValue $MaxValueLength -BorderColor 'Yellow'
            }
    
            ShowStepInfo -Msg " " -Color 'Green'
        }
        else 
        {
            $Msg = @("", "[-] Command Get-ComputerInfo not available!", "[-] Skipping retrieve computer info section...", "")
            ShowStepInfo -Msg $Msg -Color 'Red'
        }
    }
    catch 
    {
        $Msg = ("", $_.Exception.Message , "")
        ShowStepInfo -Msg $Msg -Color Red
    }

}

function RetrieveHotFixes()
{
    try 
    {
        $HotFixCmdTest = CheckCommandExists -Command Get-HotFix

        if ($HotFixCmdTest)
        {
            $Msg = @("", "[+] Retrieving HotFix info...", "")
            ShowStepInfo -Msg $Msg -Color 'Green'
    
            Get-HotFix | Select-Object Description, HotFixID, InstalledBy, InstalledOn, CsName | Sort-Object -Property InstalledOn -Descending | Format-Table
        }
        else 
        {
            $Msg = @("", "[-] Command Get-HotFix not available!", "[-] Skipping retrieve HotFix section...", "")
            ShowStepInfo -Msg $Msg -Color 'Red'
        }
    }
    catch 
    {
        $Msg = ("", $_.Exception.Message , "")
        ShowStepInfo -Msg $Msg -Color Red
    }

}

function RetrieveEnvVariables()
{
    try 
    {
        $EnvVarList = @('USERNAME', 'USERPROFILE')
        $EnvVarHT = @{'USERNAME' = "" ; 'USERPROFILE' = ""}
    
        $EnvVarHT['USERNAME'] = $Env:USERNAME
        $EnvVarHT['USERPROFILE'] = $Env:USERPROFILE
    
        $EnvVarBool = $false
    
        foreach ($value_val in $EnvVarHT.Values)
        {
            if($value_val)
            {
                $EnvVarBool = $true
                break
            }
        }
    
        if ($EnvVarBool)
        {
            $Msg = @("", "[+] Retrieving USERNAME and USERPROFILE environment variables...", "")
            ShowStepInfo -Msg $Msg -Color 'Green'
    
            $MaxKeyLength = ($EnvVarHT.Keys | Measure-Object -Maximum -Property Length).Maximum
            $MaxValueLength = ($EnvVarHT.Values | Measure-Object -Maximum -Property Length).Maximum
    
            PrintTableBorder -MaxLengthProperty $MaxKeyLength -MaxLengthValue $MaxValueLength -BorderColor 'DarkYellow'
            PrintTableRow -MaxLengthProperty $MaxKeyLength -MaxLengthValue $MaxValueLength -Property 'Property' -Value 'Value' -RowColor 'DarkYellow'
            PrintTableBorder -MaxLengthProperty $MaxKeyLength -MaxLengthValue $MaxValueLength -BorderColor 'DarkYellow'
    
            foreach ($EnvVar in $EnvVarList)
            {
                PrintTableRow -MaxLengthProperty $MaxKeyLength -MaxLengthValue $MaxValueLength -Property $EnvVar -Value $EnvVarHT[$EnvVar] -RowColor 'Yellow'
                PrintTableBorder -MaxLengthProperty $MaxKeyLength -MaxLengthValue $MaxValueLength -BorderColor 'Yellow'
            }
        }
        else 
        {
            $Msg = @("", "[-] Could not retrieve USERNAME, USERPROFILE environment variables!")
            ShowStepInfo -Msg $Msg -Color 'Red'
        }
    
        $PathDirList = $Env:Path
        
        if ($PathDirList)
        {
            $Msg = @("", "[+] Retrieving Directories in PATH...", "", "Path Directories", "----------------")
            ShowStepInfo -Msg $Msg -Color 'Green'
    
            foreach ($PathDir in $PathDirList.Split(';'))
            {
                Write-Host -Object $PathDir
            }
    
            ShowStepInfo -Msg " " -Color 'Green'
        }
        else 
        {
            $Msg = @("", "[-] Could not retrieve Path directories!", "")
            ShowStepInfo -Msg $Msg -Color 'Red'
        }
    }
    catch 
    {
        $Msg = ("", $_.Exception.Message , "")
        ShowStepInfo -Msg $Msg -Color Red
    }

}

function RetrieveUserGroupInfo()
{
    try 
    {
        $UserCmdTest = CheckCommandExists -Command Get-LocalUser

        if ($UserCmdTest)
        {
            $Msg = @("", "[+] Retrieving list of users...")
            ShowStepInfo -Msg $Msg -Color 'Green'
    
            Get-LocalUser | Select-Object Name, Enabled, LastLogon, AccountExpires, PasswordRequired, PasswordLastSet, PasswordExpires | Format-Table
        }
        else 
        {
            $Msg = @("", "[-] Command Get-LocalUser not available!", "[-] Skipping retrieve users info section...", "")
            ShowStepInfo -Msg $Msg -Color 'Red'
        }
    
        $GroupCmdTest = CheckCommandExists -Command Get-LocalGroup
    
        if ($GroupCmdTest)
        {
            $Msg = @("[+] Retrieving list of groups...")
            ShowStepInfo -Msg $Msg -Color 'Green'
    
            Get-LocalGroup | Select-Object Name, ObjectClass, PrincipalSource, SID | Format-Table
        }
        else
        {
            $Msg = @("[-] Command Get-LocalGroup not available!", "[-] Skipping retrieve groups info section...", "")
            ShowStepInfo -Msg $Msg -Color 'Red'
        }
    
        $GroupMemberCmdTest = CheckCommandExists -Command Get-LocalGroupMember
    
        if ($GroupMemberCmdTest)
        {
            $Msg = @("[+] Retrieving list of groups where current user is member...", "")
            ShowStepInfo -Msg $Msg -Color 'Green'
    
            $GroupList = Get-LocalGroup
    
            foreach ($Group in $GroupList)
            {
                if (Get-LocalGroupMember -Name $Group -Member $Env:USERNAME -ErrorAction SilentlyContinue)
                {
                    Write-Host -Object $Group -ForegroundColor 'Yellow'
                }
            }
    
            $Msg = @("", "[+] Retrieving list of members for Administrator group...")
            ShowStepInfo -Msg $Msg -Color 'Green'
    
            $AdminGroup = 'Administrators'
            Get-LocalGroupMember -Group $AdminGroup -ErrorAction SilentlyContinue | Select-Object ObjectClass, Name, PrincipalSource, SID | Format-Table
        }
        else
        {
            $Msg = @("[-] Command Get-LocalGroupMember not available!", "[-] Skipping retrieve groups where current user is member info section...", "")
            ShowStepInfo -Msg $Msg -Color 'Red'
        }
    
        $WhoAmICmdTest = CheckCommandExists -Command whoami
    
        if ($WhoAmICmdTest)
        {
            $Msg = @("[+] Retrieving list of privileges for current user...")
            ShowStepInfo -Msg $Msg -Color 'Green'
    
            whoami /priv
    
            ShowStepInfo -Msg " " -Color 'Green'
        }
        else
        {
            $Msg = @("[-] Command whoami not available!", "[-] Skipping retrieve privileges for current user info section...", "")
            ShowStepInfo -Msg $Msg -Color 'Red'
        }
    }
    catch 
    {
        $Msg = ("", $_.Exception.Message , "")
        ShowStepInfo -Msg $Msg -Color Red
    }

}

function RetrieveProcesses()
{
    try 
    {
        $GetProcessCmd = CheckCommandExists -Command Get-Process

        if ($GetProcessCmd)
        {
            $Msg = @("", "[+] Retrieving list of running processes...")
            ShowStepInfo -Msg $Msg -Color 'Green'
    
            Get-Process | Select-Object Id, Name, Path | Format-Table
        }
        else 
        {
            $Msg = @("", "[-] Command Get-Process not available!", "[-] Skipping retrieve list of running processes info section...", "")
            ShowStepInfo -Msg $Msg -Color 'Red'
        }        
    }
    catch 
    {
        $Msg = ("", $_.Exception.Message , "")
        ShowStepInfo -Msg $Msg -Color Red
    }

}

function RetrieveServices()
{
    try 
    {
        $GetServiceCmd = CheckCommandExists -Command Get-Service

        if ($GetServiceCmd)
        {
            $Msg = @("", "[+] Retrieving list of running services...")
            ShowStepInfo -Msg $Msg -Color 'Green'
    
            Get-Service | Where-Object { $_.Status -eq 'Running' } | Select-Object Name, DisplayName, Status, StartType, CanStop | Format-Table
        }
        else
        {
            $Msg = @("", "[-] Command Get-Service not available!", "[-] Skipping retrieve list of running services info section...", "")
            ShowStepInfo -Msg $Msg -Color 'Red'
        }        
    }
    catch 
    {
        $Msg = ("", $_.Exception.Message , "")
        ShowStepInfo -Msg $Msg -Color Red
    }

}

function RetrieveShares()
{
    try 
    {
        $GetSharesCmd = CheckCommandExists -Command Get-SmbShare

        if ($GetSharesCmd)
        {
            $Msg = @("", "[+] Retrieving list of shares...")
            ShowStepInfo -Msg $Msg -Color 'Green'
    
            Get-SmbShare | Select-Object Name, ScopeName, Path, Description, CurrentUsers | Format-Table
        }
        else
        {
            $Msg = @("", "[-] Command Get-SmbShare not available!", "[-] Skipping retrieve list of shares info section...", "")
            ShowStepInfo -Msg $Msg -Color 'Red'
        }
    }
    catch 
    {
        $Msg = ("", $_.Exception.Message , "")
        ShowStepInfo -Msg $Msg -Color Red
    }

}

function RetrieveSoftware()
{
    try 
    {
        $CheckSoftwareCmd = CheckCommandExists -Command Get-WmiObject

        if ($CheckSoftwareCmd)
        {
            $Msg = @("", "[+] Retrieving list of software...")
            ShowStepInfo -Msg $Msg -Color 'Green'
    
            Get-WmiObject -Class Win32_Product | Select-Object Name, Version, InstallDate, InstallLocation, Vendor | Format-Table
        }
        else
        {
            $Msg = @("", "[-] Command Get-WmiObject not available!", "[-] Skipping retrieve list of software info section...", "")
            ShowStepInfo -Msg $Msg -Color 'Red'
        }
    }
    catch 
    {
        $Msg = ("", $_.Exception.Message , "")
        ShowStepInfo -Msg $Msg -Color Red
    }

}

function RetrieveScheduledTasks()
{
    try 
    {
        $CheckScheduledTasksCmd = CheckCommandExists -Command Get-ScheduledTask

        if ($CheckScheduledTasksCmd)
        {
            $Msg = @("", "[+] Retrieving list of available scheduled tasks...", "[+] Excluded the tasks from Microsoft Path")
            ShowStepInfo -Msg $Msg -Color 'Green'
    
            Get-ScheduledTask | Where-Object { $_.TaskPath -notlike '*Microsoft*' } | Select-Object TaskName, TaskPath, State | Format-Table
        }
        else
        {
            $Msg = @("", "[-] Command Get-ScheduledTask not available!", "[-] Skipping retrieve list of available scheduled tasks...", "")
            ShowStepInfo -Msg $Msg -Color 'Red'
        }
    }
    catch 
    {
        $Msg = ("", $_.Exception.Message , "")
        ShowStepInfo -Msg $Msg -Color Red
    }

}

function RetrieveAntiVirus()
{
    try 
    {
        $CheckServiceCmd = CheckCommandExists -Command Get-Service

        if ($CheckServiceCmd)
        {
            $Msg = @("", "[+] Retrieving status for Microsoft Defender...")
            ShowStepInfo -Msg $Msg -Color 'Green'
    
            Get-Service -Name WinDefend | Select-Object Status, Name, DisplayName | Format-Table
        }
        else
        {
            $Msg = @("", "[-] Command Get-Service not available!", "[-] Skipping retrieve status for Microsoft Defender...")
            ShowStepInfo -Msg $Msg -Color 'Red'
        }
    
        $CheckAMCmd = CheckCommandExists -Command Get-MpComputerStatus
    
        if ($CheckAMCmd)
        {
            $Msg = @("", "[+] Retrieving status for antimalware software...")
            ShowStepInfo -Msg $Msg -Color 'Green'
    
            Get-MpComputerStatus | Select-Object AMRunningMode, AMServiceEnabled, AntivirusEnabled, AntivirusSignatureLastUpdated, 
            AntivirusSignatureVersion | Format-List
        }
        else
        {
            $Msg = @("", "[-] Command Get-MpComputerStatus not available!", "[-] Skipping retrieve status for antimalware software...")
            ShowStepInfo -Msg $Msg -Color 'Red'
        }
    
        $CheckAVSoftCmd = CheckCommandExists -Command Get-CimInstance
    
        if ($CheckAVSoftCmd)
        {
            $Msg = @("", "[+] Retrieving status for installed antivirus...")
            ShowStepInfo -Msg $Msg -Color 'Green'
    
            Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntivirusProduct | Select-Object displayName, 
                            instanceGuid, pathToSignedProductExe, pathToSignedReportingExe, productState, timestamp | Format-List
        }
        else
        {
            $Msg = @("", "[-] Command Get-CimInstance not available!", "[-] Skipping retrieve status for installed antivirus...", "")
            ShowStepInfo -Msg $Msg -Color 'Red'
        }       
    }
    catch 
    {
        $Msg = ("", $_.Exception.Message , "")
        ShowStepInfo -Msg $Msg -Color Red
    }

}

function RunMain()
{
    ShowHeader
    
    ShowSection -Message "Start Computer Info Section" -Color 'DarkYellow'
    RetrieveComputerInfo    
    ShowSection -Message "End Computer Info Section" -Color 'DarkYellow'
    
    ShowSection -Message "Start HotFix Section" -Color 'DarkYellow'
    RetrieveHotFixes
    ShowSection -Message "End HotFix Section" -Color 'DarkYellow'
    
    ShowSection -Message "Start Environment Variable Section" -Color 'DarkYellow'
    RetrieveEnvVariables
    ShowSection -Message "End Environment Variable Section" -Color 'DarkYellow'
    
    ShowSection -Message "Start Users & Groups Section" -Color 'DarkYellow'
    RetrieveUserGroupInfo
    ShowSection -Message "End Users & Groups Section" -Color 'DarkYellow'
    
    ShowSection -Message "Start Processes Section" -Color 'DarkYellow'
    RetrieveProcesses
    ShowSection -Message "End Processes Section" -Color 'DarkYellow'
    
    ShowSection -Message "Start Services Section" -Color 'DarkYellow'
    RetrieveServices
    ShowSection -Message "End Services Section" -Color 'DarkYellow'
    
    ShowSection -Message "Start Shares Section" -Color 'DarkYellow'
    RetrieveShares
    ShowSection -Message "End Shares Section" -Color 'DarkYellow'
    
    ShowSection -Message "Start Software Section" -Color 'DarkYellow'
    RetrieveSoftware
    ShowSection -Message "End Software Section" -Color 'DarkYellow'
    
    ShowSection -Message "Start Scheduled Tasks Section" -Color 'DarkYellow'
    RetrieveScheduledTasks
    ShowSection -Message "End Scheduled Tasks Section" -Color 'DarkYellow'
    
    ShowSection -Message "Start AntiVirus Section" -Color 'DarkYellow'
    RetrieveAntiVirus
    ShowSection -Message "End AntiVirus Section" -Color 'DarkYellow' 
}

RunMain