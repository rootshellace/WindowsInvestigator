# Check if the commands are available

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

function PrintTableHeader([Int32]$MaxLengthProperty, [Int32]$MaxLengthValue, [string]$Property, [string]$Value, [string]$BorderColor, [string]$RowColor)
{
    PrintTableBorder -MaxLengthProperty $MaxLengthProperty -MaxLengthValue $MaxLengthValue -Color $BorderColor
    PrintTableRow -MaxLengthProperty $MaxLengthProperty -MaxLengthValue $MaxLengthValue -Property $Property -Value $Value -Color $RowColor
    PrintTableBorder -MaxLengthProperty $MaxLengthProperty -MaxLengthValue $MaxLengthValue -Color $BorderColor
}

function RetrieveComputerInfo()
{
    $ComputerInfoCmdTest = CheckCommandExists -Command Get-ComputerInfo
    
    if ($ComputerInfoCmdTest)
    {
        Write-Host -Object ""
        Write-Host -Object "[+] Retrieving computer info..."
        Write-Host -Object ""

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

        PrintTableBorder -MaxLengthProperty $MaxKeyLength -MaxLengthValue $MaxValueLength -BorderColor 'Yellow'
        PrintTableRow -MaxLengthProperty $MaxKeyLength -MaxLengthValue $MaxValueLength -Property 'Property' -Value 'Value' -RowColor 'Yellow'
        PrintTableBorder -MaxLengthProperty $MaxKeyLength -MaxLengthValue $MaxValueLength -BorderColor 'Yellow'

        foreach ($property in $PropertyList)
        {
            PrintTableRow -MaxLengthProperty $MaxKeyLength -MaxLengthValue $MaxValueLength -Property $property -Value $PropertyHT[$property] -RowColor 'Green'
            PrintTableBorder -MaxLengthProperty $MaxKeyLength -MaxLengthValue $MaxValueLength -BorderColor 'Green'
        }
        Write-Host -Object ""
    }
    else 
    {
        Write-Host -Object ""
        Write-Host -Object "[-] Command Get-ComputerInfo not available!"
        Write-Host -Object "[-] Skipping retrieve computer info section..."
        Write-Host -Object ""
    }
}

function RetrieveHotFixes()
{
    $HotFixCmdTest = CheckCommandExists -Command Get-HotFix

    if ($HotFixCmdTest)
    {
        Write-Host -Object ""
        Write-Host -Object "[+] Retrieving HotFix info..."
        Write-Host -Object ""

        Get-HotFix | Select-Object Description, HotFixID, InstalledBy, InstalledOn, CsName | Sort-Object -Property InstalledOn -Descending | Format-Table
    }
    else 
    {
        Write-Host -Object ""
        Write-Host -Object "[-] Command Get-HotFix not available!"
        Write-Host -Object "[-] Skipping retrieve HotFix section..."
        Write-Host -Object ""
    }
}

function RetrieveEnvVariables()
{
    $EnvVarList = @('USERNAME', 'USERPROFILE')
    $EnvVarHT = @{'USERNAME' = "" ; 'USERPROFILE' = ""}

    $EnvVarHT['USERNAME'] = $Env:USERNAME
    $EnvVarHT['USERPROFILE'] = $Env:USERPROFILE

    if ($EnvVarHT.Values)
    {
        Write-Host -Object ""
        Write-Host -Object "[+] Retrieving environment variables..."
        Write-Host -Object ""

        $MaxKeyLength = ($EnvVarHT.Keys | Measure-Object -Maximum -Property Length).Maximum
        $MaxValueLength = ($EnvVarHT.Values | Measure-Object -Maximum -Property Length).Maximum

        PrintTableBorder -MaxLengthProperty $MaxKeyLength -MaxLengthValue $MaxValueLength -BorderColor 'Yellow'
        PrintTableRow -MaxLengthProperty $MaxKeyLength -MaxLengthValue $MaxValueLength -Property 'Property' -Value 'Value' -RowColor 'Yellow'
        PrintTableBorder -MaxLengthProperty $MaxKeyLength -MaxLengthValue $MaxValueLength -BorderColor 'Yellow'

        foreach ($EnvVar in $EnvVarList)
        {
            PrintTableRow -MaxLengthProperty $MaxKeyLength -MaxLengthValue $MaxValueLength -Property $EnvVar -Value $EnvVarHT[$EnvVar] -RowColor 'Green'
            PrintTableBorder -MaxLengthProperty $MaxKeyLength -MaxLengthValue $MaxValueLength -BorderColor 'Green'
        }
    }
    else 
    {
        Write-Host -Object ""
        Write-Host -Object "[-] Could not retrieve environment variables!"
        Write-Host -Object ""
    }

    $PathDirList = $Env:Path.Split(';')
    
    if ($PathDirList)
    {
        Write-Host -Object ""
        Write-Host -Object "[+] Retrieving Directories in PATH..."
        Write-Host -Object ""
        Write-Host -Object "Path Directories"
        Write-Host -Object "----------------"

        foreach ($PathDir in $PathDirList)
        {
            Write-Host -Object $PathDir
        }

        Write-Host -Object ""
    }
    else 
    {
        Write-Host -Object ""
        Write-Host -Object "[-] Could not retrieve Path directories!"
        Write-Host -Object ""
    }
}

function RetrieveUserGroupInfo()
{
    $UserCmdTest = CheckCommandExists -Command Get-LocalUser

    if ($UserCmdTest)
    {
        Write-Host -Object ""
        Write-Host -Object "[+] Retrieving list of users..."
        Write-Host -Object ""

        Get-LocalUser | Select-Object Name, Enabled, LastLogon, AccountExpires, PasswordRequired, PasswordLastSet, PasswordExpires | Format-Table
    }
    else 
    {
        Write-Host -Object ""
        Write-Host -Object "[-] Command Get-LocalUser not available!"
        Write-Host -Object "[-] Skipping retrieve users info section..."
        Write-Host -Object ""
    }

    $GroupCmdTest = CheckCommandExists -Command Get-LocalGroup

    if ($GroupCmdTest)
    {
        Write-Host -Object ""
        Write-Host -Object "[+] Retrieving list of groups..."
        Write-Host -Object ""

        Get-LocalGroup | Select-Object Name, ObjectClass, PrincipalSource, SID | Format-Table
    }
    else
    {
        Write-Host -Object ""
        Write-Host -Object "[-] Command Get-LocalGroup not available!"
        Write-Host -Object "[-] Skipping retrieve groups info section..."
        Write-Host -Object ""
    }

    $GroupMemberCmdTest = CheckCommandExists -Command Get-LocalGroupMember

    if ($GroupMemberCmdTest)
    {
        Write-Host -Object ""
        Write-Host -Object "[+] Retrieving list of groups where current user is member..."
        Write-Host -Object ""

        $GroupList = Get-LocalGroup

        foreach ($Group in $GroupList)
        {
            if (Get-LocalGroupMember -Name $Group -Member $Env:USERNAME -ErrorAction SilentlyContinue)
            {
                Write-Host -Object $Group -ForegroundColor 'Green'
            }
        }

        Write-Host -Object ""

        Write-Host -Object ""
        Write-Host -Object "[+] Retrieving list of members for Administrator group..."
        Write-Host -Object ""

        $AdminGroup = 'Administrators'
        Get-LocalGroupMember -Group $AdminGroup -ErrorAction SilentlyContinue | Select-Object ObjectClass, Name, PrincipalSource, SID | Format-Table
        Write-Host -Object ""
    }
    else
    {
        Write-Host -Object ""
        Write-Host -Object "[-] Command Get-LocalGroupMember not available!"
        Write-Host -Object "[-] Skipping retrieve groups where current user is member info section..."
        Write-Host -Object ""
    }

    $WhoAmICmdTest = CheckCommandExists -Command whoami

    if ($WhoAmICmdTest)
    {
        Write-Host -Object ""
        Write-Host -Object "[+] Retrieving list of privileges for current user..."
        Write-Host -Object ""

        whoami /priv

        Write-Host -Object ""
    }
    else
    {
        Write-Host -Object ""
        Write-Host -Object "[-] Command whoami not available!"
        Write-Host -Object "[-] Skipping retrieve privileges for current user info section..."
        Write-Host -Object ""
    }
}

function RetrieveProcesses()
{
    $GetProcessCmd = CheckCommandExists -Command Get-Process

    if ($GetProcessCmd)
    {
        Write-Host -Object ""
        Write-Host -Object "[+] Retrieving list of running processes..."
        Write-Host -Object ""

        Get-Process | Select-Object Id, Name, Path | Format-Table

        Write-Host -Object ""
    }
    else 
    {
        Write-Host -Object ""
        Write-Host -Object "[-] Command Get-Process not available!"
        Write-Host -Object "[-] Skipping retrieve list of running processes info section..."
        Write-Host -Object ""
    }
}

function RetrieveServices()
{
    $GetServiceCmd = CheckCommandExists -Command Get-Service

    if ($GetServiceCmd)
    {
        Write-Host -Object ""
        Write-Host -Object "[+] Retrieving list of running services..."
        Write-Host -Object ""

        Get-Service | Where-Object { $_.Status -eq 'Running' } | Select-Object Name, DisplayName, Status, StartType, CanStop | Format-Table

        Write-Host -Object ""
    }
    else
    {
        Write-Host -Object ""
        Write-Host -Object "[-] Command Get-Service not available!"
        Write-Host -Object "[-] Skipping retrieve list of running services info section..."
        Write-Host -Object ""
    }
}

function RetrieveShares()
{
    $GetSharesCmd = CheckCommandExists -Command Get-SmbShare

    if ($GetSharesCmd)
    {
        Write-Host -Object ""
        Write-Host -Object "[+] Retrieving list of shares..."
        Write-Host -Object ""

        Get-SmbShare | Select-Object Name, ScopeName, Path, Description, CurrentUsers | Format-Table

        Write-Host -Object ""
    }
    else
    {
        Write-Host -Object ""
        Write-Host -Object "[-] Command Get-SmbShare not available!"
        Write-Host -Object "[-] Skipping retrieve list of shares info section..."
        Write-Host -Object ""
    }
}

function RetrieveSoftware()
{
    $CheckSoftwareCmd = CheckCommandExists -Command Get-WmiObject

    if ($CheckSoftwareCmd)
    {
        Write-Host -Object ""
        Write-Host -Object "[+] Retrieving list of software..."
        Write-Host -Object ""

        Get-WmiObject -Class Win32_Product | Select-Object Name, Version, InstallDate, InstallLocation, Vendor | Format-Table

        Write-Host -Object ""
    }
    else
    {
        Write-Host -Object ""
        Write-Host -Object "[-] Command Get-WmiObject not available!"
        Write-Host -Object "[-] Skipping retrieve list of software info section..."
        Write-Host -Object ""
    }
}

function RunMain()
{
    ShowSection -Message "Start Computer Info Section" -Color 'Blue'
    RetrieveComputerInfo    
    ShowSection -Message "End Computer Info Section" -Color 'Blue'
    ShowSection -Message "Start HotFix Section" -Color 'Blue'
    RetrieveHotFixes
    ShowSection -Message "End HotFix Section" -Color 'Blue'
    ShowSection -Message "Start Environment Variable Section" -Color 'Blue'
    RetrieveEnvVariables
    ShowSection -Message "End Environment Variable Section" -Color 'Blue'
    ShowSection -Message "Start Users & Groups Section" -Color 'Blue'
    RetrieveUserGroupInfo
    ShowSection -Message "End Users & Groups Section" -Color 'Blue'
    ShowSection -Message "Start Processes Section" -Color 'Blue'
    RetrieveProcesses
    ShowSection -Message "End Processes Section" -Color 'Blue'
    ShowSection -Message "Start Services Section" -Color 'Blue'
    RetrieveServices
    ShowSection -Message "End Services Section" -Color 'Blue'
    ShowSection -Message "Start Shares Section" -Color 'Blue'
    RetrieveShares
    ShowSection -Message "End Shares Section" -Color 'Blue'
    ShowSection -Message "Start Software Section" -Color 'Blue'
    RetrieveSoftware
    ShowSection -Message "End Software Section" -Color 'Blue'
}

RunMain