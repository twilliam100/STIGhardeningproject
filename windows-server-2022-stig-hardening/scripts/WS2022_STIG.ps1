# PowerSTIG DSC configuration: Windows Server 2022 Member Server STIG
# Requires: Install-Module -Name PowerSTIG -Scope AllUsers
#           Set-Item -Path WSMan:\localhost\MaxEnvelopeSizekb -Value 8192
# Usage:    & C:\STIG\WS2022_STIG.ps1                                  (compiles the MOF)
#           Test-DscConfiguration -ReferenceConfiguration C:\STIG\WS2022\localhost.mof   (preview)
#           Start-DscConfiguration -Path C:\STIG\WS2022 -Wait -Verbose -Force           (apply)
# Test on a snapshot first: STIG settings can lock out accounts and rename built-in accounts.

Configuration WS2022_STIG
{
    Import-DscResource -ModuleName PowerStig
    Node localhost
    {
        WindowsServer BaseLine
        {
            OsVersion = '2022'
            OsRole    = 'MS'
        }
    }
}

WS2022_STIG -OutputPath C:\STIG\WS2022
