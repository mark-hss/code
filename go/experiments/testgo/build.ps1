$ErrorActionPreference = "Stop"

$env:CGO_ENABLED = "0"
$env:GOOS = "linux"
$env:GOARCH = "amd64"

go build -trimpath -ldflags="-s -w" -o "dist/hello-linux-amd64" .

if ($LASTEXITCODE -ne 0) {
    throw "Go build failed"
}

Write-Host "Created dist/hello-linux-amd64"