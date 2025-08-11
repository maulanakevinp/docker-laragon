param(
    [Parameter(Mandatory = $true)]
    [string]$Domain,

    [string]$IP = "127.0.0.1"
)

# ==== Cek apakah sudah admin ====
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    Write-Host "Meminta hak Administrator..."
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`" -Domain `"$Domain`" -IP `"$IP`"" -Verb RunAs
    exit
}

# ==== Path file hosts ====
$HostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"

# ==== Cek apakah domain sudah ada ====
$Exists = Select-String -Path $HostsPath -Pattern "\b$Domain\b" -Quiet

if ($Exists) {
    Write-Host "Domain $Domain sudah ada di hosts."
} else {
    "$IP`t$Domain" | Out-File -FilePath $HostsPath -Encoding UTF8 -Append
    Write-Host "Domain $Domain berhasil ditambahkan ke hosts."
}

# ==== Flush DNS ====
ipconfig /flushdns | Out-Null
Write-Host "Selesai!"
