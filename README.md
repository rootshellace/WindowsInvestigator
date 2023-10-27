# WindowsInvestigator by rootshellace

This is a Powershell script which retrieves various info from a computer. Can be used in enumeration step.

## Prerequisites

The script itself doesn't have any prerequisites, since it doesn't use any additional modules.
However, there is a requirement for executing Powershell scripts, and it's related to Execution Policy.

To check you current settings for execution policy, just run the following command in Powershell:

```powershell
Get-ExecutionPolicy -List
```

You should receive an output similar to this:

```
        Scope ExecutionPolicy
        ----- ---------------
MachinePolicy       Undefined
   UserPolicy       Undefined
      Process       Undefined
  CurrentUser    RemoteSigned
 LocalMachine       Undefined
```

By default, the value for *CurrentUser* is *Restricted*. In order to be able to execute a script, it must be set to *RemoteSigned*. Keep in mind that this action must be performed by an administrator. If you have admin permissions, just execute the command below:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```
In case you don't have admin rights, someone who has must execute the above command.

There is another option when you can execute a script without having *RemoteSigned* for *CurrentUser*. As long as for *LocalMachine* you have *RemoteSigned* and for *CurrentUser* is *Undefined*, you will still be able to run Powershell scripts. So, the policy below will allow you to run this tool:

```
        Scope ExecutionPolicy
        ----- ---------------
MachinePolicy       Undefined
   UserPolicy       Undefined
      Process       Undefined
  CurrentUser       Undefined
 LocalMachine    RemoteSigned
```

The important thing is to not have *Restricted* either for *CurrentUser* or for *LocalMachine*. This setting won't allow you to run any script.

## Usage

There are no parameters required when running this script. Just execute the file itself and will start outputting the info.

If you are in the directory where this file is located, just run it like this:

```powershell
PS C:\Users\myuser\WindowsInvestigator> .\WindowsInvestigator.ps1
```

In case you want to trigger the execution from a different location, just add the full path to file:

```powershell
PS C:\> C:\Users\myuser\WindowsInvestigator\WindowsInvestigator.ps1
```
