# Simple HTTP Server in PowerShell
$port = 8000
$url = "http://localhost:$port/"

# Create HTTP listener
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($url)
$listener.Start()

Write-Host "Server started: $url" -ForegroundColor Green
Write-Host "Open your browser and navigate to $url or ${url}app.html" -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host ""

try {
    while ($listener.IsListening) {
        # Wait for request
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        # Process request URL
        $localPath = $request.Url.LocalPath
        if ($localPath -eq "/") {
            $localPath = "/app.html"
        }
        
        $filePath = Join-Path $PSScriptRoot $localPath.TrimStart("/")
        
        Write-Host "$(Get-Date -Format 'HH:mm:ss') - $($request.HttpMethod) $localPath" -ForegroundColor Gray
        
        if (Test-Path $filePath -PathType Leaf) {
            # File exists
            $content = [System.IO.File]::ReadAllBytes($filePath)
            
            # Set MIME type
            $extension = [System.IO.Path]::GetExtension($filePath)
            $mimeType = switch ($extension) {
                ".html" { "text/html; charset=utf-8" }
                ".css"  { "text/css; charset=utf-8" }
                ".js"   { "application/javascript; charset=utf-8" }
                ".json" { "application/json; charset=utf-8" }
                ".png"  { "image/png" }
                ".jpg"  { "image/jpeg" }
                ".gif"  { "image/gif" }
                ".svg"  { "image/svg+xml" }
                default { "application/octet-stream" }
            }
            
            $response.ContentType = $mimeType
            $response.ContentLength64 = $content.Length
            $response.StatusCode = 200
            $response.OutputStream.Write($content, 0, $content.Length)
        } else {
            # File not found
            $response.StatusCode = 404
            $content = [System.Text.Encoding]::UTF8.GetBytes("404 - File Not Found: $localPath")
            $response.ContentLength64 = $content.Length
            $response.OutputStream.Write($content, 0, $content.Length)
        }
        
        $response.OutputStream.Close()
    }
} finally {
    $listener.Stop()
    Write-Host "Server stopped." -ForegroundColor Red
}
