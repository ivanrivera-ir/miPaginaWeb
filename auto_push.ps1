
# Script para automatizar el push a git

param (
    [string]$message = "Actualización automática $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
)

Write-Host "Iniciando proceso de actualización..." -ForegroundColor Green

# Verificar estado
git status

# Agregar cambios
Write-Host "Agregando cambios..." -ForegroundColor Cyan
git add .

# Commit
Write-Host "Realizando commit con mensaje: $message" -ForegroundColor Cyan
git commit -m "$message"

# Push
Write-Host "Subiendo cambios a remote..." -ForegroundColor Cyan
git push origin main

if ($?) {
    Write-Host "¡Proceso completado exitosamente!" -ForegroundColor Green
} else {
    Write-Host "Hubo un error al subir los cambios." -ForegroundColor Red
}
