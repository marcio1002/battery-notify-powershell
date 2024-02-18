Add-Type -AssemblyName System.Windows.Forms

$CHARGE_STATUS = 2, 3, 6, 7, 8, 9
$DISCHARGE_STATUS = 1
$DEFAULT_MAXIMUNBATTERY = 100
$DEFAULT_MINIMUNBATTERRY = 20

<#
    .SYNOPSIS
    
#>
function _ShowAlert {
    param (
        [string] $Title,
        [string] $Message,

        [ValidateSet('OK', 'OKCancel', 'YesNo', 'YesNo', 'YesNoCancel', 'RetryCancel', 'CancelTryContinue', 'AbortRetryIgnore')] 
        [string] $ButtonType,

        [ValidateSet('None', 'Information', 'Warning', 'Error', 'Question')] 
        [string] $IconType
    )

    $DefaultButton =  [System.Enum]::Parse([System.Windows.Forms.MessageBoxButtons], 'OK')
    $Buttons = [System.Enum]::Parse([System.Windows.Forms.MessageBoxButtons], $ButtonType)
    $Icon =  [System.Enum]::Parse([System.Windows.Forms.MessageBoxIcon], $IconType)
    $Options = [System.Windows.Forms.MessageBoxOptions]::ServiceNotification

    [System.Windows.Forms.MessageBox]::Show(
        $Message,
        $Title,
        $Buttons,
        $Icon,
        $DefaultButton,
        $Options 
    )
}


<#

#>
function Watch-BatteryStatus {
    $ShowAlert = $true;
    $lastBatteryStatus = 0;

    while ($true) {
        $Battery = Get-WmiObject -Class Win32_Battery

        $BatteryStatus = $Battery.BatteryStatus ?? 0
        $Percent = $Battery.EstimatedChargeRemaining ?? 0;
        $MaximunBattery = $Global:MaximunBattery ?? $DEFAULT_MAXIMUNBATTERY
        $MinimunBatterry = $Global:MinimunBatterry ?? $DEFAULT_MINIMUNBATTERRY

        # Write-Host "val max: $MaximunBattery", "val min: $MinimunBatterry", "status:$BatteryStatus", "percent:$Percent"

        if (
            -not $ShowAlert -and
            $lastBatteryStatus -ne $BatteryStatus
        ) {
            $ShowAlert = $true
        }

        if (
            $ShowAlert -and 
            $null -ne $Battery -and 
            $CHARGE_STATUS -eq $BatteryStatus -and 
            $Percent -ge $MaximunBattery
        ) {
            $ShowAlert = $false;
            $lastBatteryStatus = $BatteryStatus

            _ShowAlert `
                -Title "Bateria Carregada" `
                -Message "Bateria carregada em $Percent%, já pode retirar da tomada" `
                -Button 'OK' `
                -Icon 'Information' `
        
        }

        if (
            $ShowAlert -and 
            $null -ne $Battery -and 
            $BatteryStatus -eq $DISCHARGE_STATUS -and 
            $Percent -le $MinimunBatterry
        ) {
            $ShowAlert = $false;
            $lastBatteryStatus = $BatteryStatus

            _ShowAlert `
                -Title "Bateria Descarregando" `
                -Message "Bateria em $Percent%, Coloque em uma tomada para carregar" `
                -Button 'OK' `
                -Icon 'Warning' `
        
        }
    
        Start-Sleep -Seconds 1
    }
}