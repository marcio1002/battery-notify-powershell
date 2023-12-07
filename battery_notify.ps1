Add-Type -AssemblyName System.Windows.Forms



# Função para envio de alerta
function AlertBox {
    param (
        [string] $Title,
        [string] $Message,

        [ValidateSet('OK', 'OKCancel', 'YesNo', 'YesNo', 'YesNoCancel', 'RetryCancel', 'CancelTryContinue', 'AbortRetryIgnore')] 
        [string] $ButtonType,

        [ValidateSet('None','Information','Warning','Error','Question')] 
        [string] $IconType
    )

    $Button = [System.Enum]::Parse([System.Windows.Forms.MessageBoxButtons], $ButtonType)
    $Icon = [System.Enum]::Parse([System.Windows.Forms.MessageBoxIcon], $IconType)

    [System.Windows.Forms.MessageBox]::Show(
        $Message,
        $Title,
        $Button,
        $Icon
    )
}

# Função para verificar o status da bateria
function CheckBatteryStatus {
    $battery = Get-WmiObject -Class Win32_Battery

    while ($true) {
        if ($battery -and $battery.BatteryStatus -eq 2 -and $battery.EstimatedChargeRemaining -eq 73) {
            $percent = $battery.EstimatedChargeRemaining

            AlertBox `
                -Title "Bateria Carregada" `
                -Message "Bateria carregada em $percent%, já pode retirar da tomada" `
                -Button 'OK' `
                -Icon 'Information' `
            
        }

        if ($battery -and $battery.BatteryStatus -eq 1 -and $battery.EstimatedChargeRemaining -le 45) {
            $percent = $battery.EstimatedChargeRemaining

             AlertBox 
                -Title "Bateria Descarregando" `
                -Message "Bateria carregada em $percent%, Coloque em uma tomada para carregar a bateria" `
                -Button 'OK' `
                -Icon 'Warning' `
        }
    
        # Aguarde um tempo antes de verificar novamente
        Start-Sleep -Seconds 60
    }
}

CheckBatteryStatus