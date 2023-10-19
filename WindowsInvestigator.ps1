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
    $EnvVarList = @('USERNAME', 'USERPROFILE') #, 'Path')
    $EnvVarHT = @{'USERNAME' = "" ; 'USERPROFILE' = ""} # ; 'Path' = ""}

    $EnvVarHT['USERNAME'] = $Env:USERNAME
    $EnvVarHT['USERPROFILE'] = $Env:USERPROFILE
    #$EnvVarHT['Path'] = $Env:Path

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
    }
    else 
    {
        Write-Host -Object ""
        Write-Host -Object "[-] Could not retrieve Path directories!"
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
}

RunMain