# Check if the commands are available

function CheckCommandExists 
{
    $CommandsUsed = @('Get-Date', 'Get-Process', 'Get-FakeTest')
    $CommandExists = @{}

    for ($i=0; $i -lt $CommandsUsed.Length; $i++)
    {
        Write-Host -Object ("Checking command " + $CommandsUsed[$i])

        $CmdTestResult = (Get-Command -Name $CommandsUsed[$i] -ErrorAction SilentlyContinue)
        if ($CmdTestResult)
        {
            $CommandExists[$CommandsUsed[$i]] = 1
            Write-Host -Object ("Command " + $CommandsUsed[$i] + " exists!")
        }
        else 
        {
            $CommandExists[$CommandsUsed[$i]] = 0
            Write-Host -Object ("Command " + $CommandsUsed[$i] + " does not exist!")
        }
    }

    Write-Host -Object $CommandExists
}

CheckCommandExists