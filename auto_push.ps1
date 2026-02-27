<#
.SYNOPSIS
    Script para automatizar la subida de cambios (git add, commit y push) a GitLab, GitHub o ambos.
#>

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "        Automatización de Git Push      " -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# 1. Comprobar si hay cambios pendientes
$gitStatus = git status --porcelain
if (-not $gitStatus) {
    Write-Host "No hay cambios nuevos para hacer commit. ¡El directorio está limpio!" -ForegroundColor Green
    exit
}

# 2. Solicitar el mensaje de commit
$commitMessage = Read-Host "📝 Introduce el mensaje del commit"
if ([string]::IsNullOrWhiteSpace($commitMessage)) {
    Write-Host "El mensaje no puede estar vacío. Operación cancelada." -ForegroundColor Red
    exit
}

# 3. Mostrar menú para elegir el destino
Write-Host "`n¿A dónde deseas subir tus cambios?" -ForegroundColor Yellow
Write-Host "1. GitLab"
Write-Host "2. GitHub"
Write-Host "3. Ambos destinos"
$opcion = Read-Host "Elige una opción (1/2/3)"

# -------------------------------------------------------------------
# CONFIGURACIÓN DE REMOTES
# Cambia estos valores si tus remotes se llaman diferente.
# Por ejemplo, si GitHub es tu repositorio principal, quizás se llame "origin".
$gitlabRemote = "gitlab"
$githubRemote = "github"
# -------------------------------------------------------------------

# 4. Obtener el nombre de la rama actual
$currentBranch = git rev-parse --abbrev-ref HEAD

# 5. Añadir cambios y crear commit
Write-Host "`n[1/2] Añadiendo archivos (git add .) ..." -ForegroundColor Cyan
git add .

Write-Host "[2/2] Creando commit ..." -ForegroundColor Cyan
git commit -m "$commitMessage" | Out-Null
Write-Host "Commit creado localmente.`n" -ForegroundColor Green

# 6. Función auxiliar para ejecutar el push
function Push-Repo {
    param ( [string]$RemoteName )
    
    # Comprobar si el remote existe configurado en Git
    $remoteExists = git remote | Where-Object { $_ -eq $RemoteName }
    if (-not $remoteExists) {
        Write-Host "❌ Error: No se encontró un origen / remote llamado '$RemoteName'." -ForegroundColor Red
        Write-Host "   Puedes añadirlo con este comando:" -ForegroundColor Gray
        Write-Host "   git remote add $RemoteName <url-del-repositorio>`n" -ForegroundColor Gray
        return
    }

    Write-Host "🚀 Subiendo a $RemoteName (rama: $currentBranch)..." -ForegroundColor Cyan
    git push $RemoteName $currentBranch
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ ¡Cambios subidos exitosamente a $RemoteName!`n" -ForegroundColor Green
    }
    else {
        Write-Host "⚠ Hubo un problema al subir a $RemoteName.`n" -ForegroundColor Red
    }
}

# 7. Ejecutar según la selección del usuario
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
        Write-Host "Opción inválida. Tus cambios se guardaron localmente (commit), pero no se subieron (push)." -ForegroundColor Red
    }
}

Write-Host "Operación finalizada." -ForegroundColor Cyan
