# V1 : Vérification basique d'un service sous Windows
$ServiceName = "Spooler"

$service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue

if ($service -and $service.Status -eq 'Running') {
    Write-Host "Le service $ServiceName est en marche." -ForegroundColor Green
} else {
    Write-Host "Le service $ServiceName est arrêté." -ForegroundColor Red
}