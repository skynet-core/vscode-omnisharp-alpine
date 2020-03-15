$filePath = $(ls /home/vscode/.vscode-server/extensions/ms-dotnettools.csharp-*/.omnisharp/*/run)
$filePath = ($filePath -split '\n')[0]

(Get-Content -Path $filePath -Raw).Replace('mono_cmd=${bin_dir}/mono', 'mono_cmd=/usr/bin/mono') | Set-Content -Path $filePath

dotnet restore