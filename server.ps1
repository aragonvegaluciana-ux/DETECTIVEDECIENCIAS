$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://localhost:8080/')
$listener.Start()

Write-Host "Servidor iniciado en http://localhost:8080/"

try {
    while ($listener.IsListening) {
        try {
            $context = $listener.GetContext()
            $request = $context.Request
            $response = $context.Response
            
            $localPath = $request.Url.LocalPath
            if ($localPath -eq "/") { $localPath = "/index.html" }
            
            $baseDir = $PSScriptRoot
            if ([string]::IsNullOrEmpty($baseDir)) { $baseDir = (Get-Location).Path }
            $filePath = Join-Path $baseDir $localPath
            $filePath = $filePath.Replace('/', '\')
            
            Write-Host "Peticion: $localPath -> $filePath"

            if (Test-Path $filePath -PathType Leaf) {
                $ext = [System.IO.Path]::GetExtension($filePath)
                if ($ext -eq ".html") { $response.ContentType = "text/html; charset=utf-8" }
                elseif ($ext -eq ".css") { $response.ContentType = "text/css" }
                elseif ($ext -eq ".js") { $response.ContentType = "application/javascript" }
                
                $content = [System.IO.File]::ReadAllBytes($filePath)
                $response.ContentLength64 = $content.Length
                $response.OutputStream.Write($content, 0, $content.Length)
            } else {
                $response.StatusCode = 404
            }
        } catch {
            Write-Host "Error sirviendo: $_"
        } finally {
            $response.Close()
        }
    }
}
finally {
    $listener.Stop()
}
