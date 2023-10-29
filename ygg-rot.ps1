$DAYS_KEEP = 7

$ygg = Get-Service -Name Yggdrasil -ErrorAction SilentlyContinue

if( $ygg -eq $null) {
    Exit 0
}

$ygg_state = $ygg.Status
if( $ygg_state -eq "Running") {
    $ygg_int = (Get-NetAdapter | Where-Object { $_.Name -like "ygg*" } | Select-Object -First 1).Name
    
    $ygg | Stop-Service 
}


$logfile = "$env:ALLUSERSPROFILE\Yggdrasil\yggdrasil.log"
$target_file = "$env:ALLUSERSPROFILE\Yggdrasil\yggdrasil.log.$(Get-Date -Format "yyyyMMdd")"
Move-Item -Path $logfile -Destination $target_file -ErrorAction SilentlyContinue


if( $ygg_state -eq "Running") {
    $ygg | Start-Service
}

$cdate = (Get-Date).AddDays(- $DAYS_KEEP)

Get-ChildItem -Path $env:ALLUSERSPROFILE\Yggdrasil\yggdrasil.log.* `
    | Where-Object { $_.LastWriteTime -le $cdate } `
    | Remove-Item

Start-Sleep -Seconds 12
Get-NetAdapter | Where-Object { $_.Name -like "ygg*" } -ErrorAction SilentlyContinue > $null
while( (Get-NetAdapter | Where-Object { $_.Name -like "ygg*" } -ErrorAction SilentlyContinue) -eq $null) {
    $ygg | Stop-Service
    Start-Sleep -Seconds 3
    $ygg | Start-Service
    Start-Sleep -Seconds 3
}