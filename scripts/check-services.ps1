# V2 : Liste de services Windows et compte rendu structuré
$Services = @("Spooler", "W32Time", "TermService")
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Write-Host "=== Compte rendu des services Windows - $Date ==="

foreach ($svcName in $Services) {
    $svc = Get-Service -Name $svcName -ErrorAction SilentlyContinue
    if ($svc -and $svc.Status -eq 'Running') {
        Write-Host "[OK] Le service $svcName est actif."
    } else {
        Write-Host "[ALERTE] Le service $svcName est inactif."
    }
}