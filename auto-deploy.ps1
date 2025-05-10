$outputPath = "$env:USERPROFILE\halo-next\static"
$repoPath = "D:\gerbok\ch777777.github.io"

# 检查 Halo 是否已运行
try {
    Invoke-WebRequest -Uri "http://localhost:8090" -TimeoutSec 2 -ErrorAction Stop | Out-Null
    Write-Host "Halo 已经在运行" -ForegroundColor Green
} catch {
    Write-Host "正在启动 Halo..." -ForegroundColor Yellow
    $env:JAVA_HOME = "D:\gerbok\jdk-17.0.2"
    $env:Path = "$env:Path;$env:JAVA_HOME\bin"
    
    Start-Process -FilePath "java" -ArgumentList "-jar", "D:\gerbok\choliy\halo-app\halo-2.20.11-SNAPSHOT.jar", "--spring.config.location=file:D:\gerbok\choliy\halo-app\application.yaml" -NoNewWindow
    
    # 等待 Halo 启动
    $timeout = 60
    $started = $false
    Write-Host "等待 Halo 启动 (最多 60 秒)..." -NoNewline
    
    for ($i = 0; $i -lt $timeout; $i++) {
        try {
            Invoke-WebRequest -Uri "http://localhost:8090" -TimeoutSec 1 -ErrorAction Stop | Out-Null
            $started = $true
            Write-Host "`nHalo 已成功启动!" -ForegroundColor Green
            Start-Sleep -Seconds 5
            break
        } catch {
            Write-Host "." -NoNewline
            Start-Sleep -Seconds 1
        }
    }
    
    if (-not $started) {
        Write-Host "`nHalo 启动失败，请手动检查问题" -ForegroundColor Red
        exit
    }
}

# 创建静态文件输出目录
if (!(Test-Path -Path $outputPath)) {
    New-Item -Path $outputPath -ItemType Directory -Force | Out-Null
}
New-Item -Path "$outputPath\console" -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null

# 抓取网站内容
Write-Host "抓取网站内容..." -ForegroundColor Cyan
Invoke-WebRequest -Uri "http://localhost:8090" -OutFile "$outputPath\index.html"

# 抓取资源文件
$homePage = Invoke-WebRequest -Uri "http://localhost:8090"
$links = $homePage.Links | Where-Object { $_.href -like "*.css" -or $_.href -like "*.js" }

foreach ($link in $links) {
    $url = $link.href
    if ($url -match "^/") {
        $url = "http://localhost:8090$url"
    }
    $fileName = $url -replace ".*/"
    Invoke-WebRequest -Uri $url -OutFile "$outputPath\$fileName"
}

# 处理 GitHub Pages 仓库
Write-Host "更新 GitHub Pages 仓库..." -ForegroundColor Green
if (!(Test-Path -Path $repoPath)) {
    New-Item -Path $repoPath -ItemType Directory -Force | Out-Null
    Set-Location $repoPath
    git init
    git remote add origin "https://github.com/ch777777/ch777777.github.io.git"
} else {
    Set-Location $repoPath
    Get-ChildItem -Path $repoPath -Exclude .git,README.md,vercel.json | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}

# 复制静态文件到仓库
Copy-Item -Path "$outputPath\*" -Destination $repoPath -Recurse -Force

# 提交并推送
git add .
git commit -m "Update blog content $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
git push -u origin master

Write-Host "部署完成! 请访问 https://ch777777.github.io 查看你的博客" -ForegroundColor Green 