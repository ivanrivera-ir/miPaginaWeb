<#
.SYNOPSIS
    Script para automatizar la subida de cambios (git add, commit y push) a GitLab, GitHub o ambos.
#>

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "        Automatizacion de Git Push      " -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# 1. Comprobar si hay cambios pendientes
$gitStatus = git status --porcelain
if (-not $gitStatus) {
    Write-Host "No hay cambios nuevos para hacer commit. El directorio esta limpio." -ForegroundColor Green
    exit
}

# 2. Solicitar el mensaje de commit
$commitMessage = Read-Host "[?] Introduce el mensaje del commit (deja en blanco para usar la fecha/hora actual)"
if ([string]::IsNullOrWhiteSpace($commitMessage)) {
    $commitMessage = "Actualizacion automatica $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    Write-Host "[i] Usando mensaje por defecto: $commitMessage" -ForegroundColor Yellow
}

# 3. Mostrar menu para elegir el destino
Write-Host "`nA donde deseas subir tus cambios?" -ForegroundColor Yellow
Write-Host "1. GitLab"
Write-Host "2. GitHub"
Write-Host "3. Ambos destinos"
$opcion = Read-Host "Elige una opcion (1 / 2 / 3)"

# -------------------------------------------------------------------
# CONFIGURACION DE REMOTES
# Cambia estos valores si tus remotes se llaman diferente.
# Por ejemplo, si GitHub es tu repositorio principal, quizas se llame "origin".
$gitlabRemote = "gitlab"
$githubRemote = "github"
# -------------------------------------------------------------------

# 4. Obtener el nombre de la rama actual
$currentBranch = git rev-parse --abbrev-ref HEAD

# 5. Anadir cambios y crear commit
Write-Host "`n[1/2] Anadiendo archivos (git add .) ..." -ForegroundColor Cyan
git add .

Write-Host "[2/2] Creando commit ..." -ForegroundColor Cyan
git commit -m "$commitMessage" | Out-Null
Write-Host "Commit creado localmente.`n" -ForegroundColor Green

# 6. Funcion auxiliar para ejecutar el push
function Push-Repo {
    param ( [string]$RemoteName )
    
    # Comprobar si el remote existe configurado en Git
    $remoteExists = git remote | Where-Object { $_ -eq $RemoteName }
    if (-not $remoteExists) {
        Write-Host "[ERROR] No se encontro un origen / remote llamado '$RemoteName'." -ForegroundColor Red
        Write-Host "   Puedes anadirlo con este comando:" -ForegroundColor Gray
        Write-Host "   git remote add $RemoteName <url-del-repositorio>`n" -ForegroundColor Gray
        return
    }

    Write-Host "[!] Obteniendo cambios de $RemoteName (rama: $currentBranch)..." -ForegroundColor Cyan
    git pull $RemoteName $currentBranch --rebase

    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Hubo un conflicto o error al hacer pull de $RemoteName (`$LASTEXITCODE). Resuelvelo e intenta nuevamente." -ForegroundColor Red
        return
    }

    Write-Host "[!] Subiendo a $RemoteName (rama: $currentBranch)..." -ForegroundColor Cyan
    git push $RemoteName $currentBranch
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Cambios subidos exitosamente a $RemoteName!`n" -ForegroundColor Green
    }
    else {
        Write-Host "[WARN] Hubo un problema al subir a $RemoteName.`n" -ForegroundColor Red
    }
}

# 7. Ejecutar segun la seleccion del usuario
switch ($opcion) {
    "1" { 
        Push-Repo -RemoteName $gitlabRemote 
    }
    "2" { 
        Push-Repo -RemoteName $githubRemote 
    }
    "3" { 
        Push-Repo -RemoteName $gitlabRemote
        Push-Repo -RemoteName $githubRemote 
    }
    default {
        Write-Host "Opcion invalida. Tus cambios se guardaron localmente (commit), pero no se subieron (push)." -ForegroundColor Red
    }
}

Write-Host "Operacion finalizada." -ForegroundColor Cyan
