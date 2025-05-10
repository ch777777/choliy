$outputPath = "$env:USERPROFILE\halo-next\static"
$repoPath = "D:\gerbok\ch777777.github.io"  # 正确的仓库路径

# 1. 检查 Halo 是否在运行
Write-Host "检查 Halo 是否已启动..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8090" -TimeoutSec 5 -ErrorAction Stop
    Write-Host "Halo 已经在运行" -ForegroundColor Green
} catch {
    Write-Host "Halo 尚未启动，正在自动启动..." -ForegroundColor Cyan
    
    # 尝试启动 Halo
    $javaHome = "D:\gerbok\jdk-17.0.2"
    $env:JAVA_HOME = $javaHome
    $env:Path += ";$javaHome\bin"
    
    Start-Process -FilePath "$javaHome\bin\java.exe" -ArgumentList "-jar", "D:\gerbok\choliy\halo-app\halo-2.20.11-SNAPSHOT.jar", "--spring.config.location=file:D:\gerbok\choliy\halo-app\application.yaml" -NoNewWindow
    
    # 等待 Halo 启动
    Write-Host "等待 Halo 启动 (最多等待 60 秒)..." -ForegroundColor Yellow
    $timeout = 60
    $started = $false
    for ($i = 0; $i -lt $timeout; $i++) {
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:8090" -TimeoutSec 1 -ErrorAction Stop
            $started = $true
            Write-Host "Halo 已成功启动!" -ForegroundColor Green
            # 再等待 5 秒确保完全初始化
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

# 2. 使用 PowerShell 抓取静态页面
Write-Host "开始抓取静态页面..." -ForegroundColor Green
if (!(Test-Path -Path $outputPath)) {
    New-Item -Path $outputPath -ItemType Directory -Force
}

# 创建输出目录
New-Item -Path "$outputPath\console" -ItemType Directory -Force -ErrorAction SilentlyContinue

# 抓取首页
Write-Host "抓取首页..." -ForegroundColor Cyan
Invoke-WebRequest -Uri "http://localhost:8090" -OutFile "$outputPath\index.html"

# 抓取CSS和JS资源
Write-Host "抓取资源文件..." -ForegroundColor Cyan
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

# 抓取文章页面
Write-Host "尝试抓取文章页面..." -ForegroundColor Cyan
try {
    $articles = Invoke-WebRequest -Uri "http://localhost:8090/archives" -ErrorAction SilentlyContinue
    $articleLinks = $articles.Links | Where-Object { $_.href -like "/archives/*" -or $_.href -like "/posts/*" }
    
    New-Item -Path "$outputPath\archives" -ItemType Directory -Force -ErrorAction SilentlyContinue
    New-Item -Path "$outputPath\posts" -ItemType Directory -Force -ErrorAction SilentlyContinue
    
    foreach ($link in $articleLinks) {
        $url = $link.href
        if ($url -match "^/") {
            $url = "http://localhost:8090$url"
        }
        $relPath = $url -replace "http://localhost:8090"
        $fileName = $relPath -replace "/", "_"
        if ($fileName -ne "") {
            Invoke-WebRequest -Uri $url -OutFile "$outputPath\$fileName.html"
        }
    }
} catch {
    Write-Host "无法抓取文章页面，继续执行..." -ForegroundColor Yellow
}

# 3. 复制静态文件到 GitHub Pages 仓库
Write-Host "将静态文件复制到 GitHub Pages 仓库..." -ForegroundColor Green
if (!(Test-Path -Path $repoPath)) {
    New-Item -Path $repoPath -ItemType Directory -Force
    Set-Location $repoPath
    git init
    git remote add origin "https://github.com/ch777777/ch777777.github.io.git"
} else {
    Set-Location $repoPath
    # 清空仓库，但保留 .git 目录和README.md文件
    Get-ChildItem -Path $repoPath -Exclude .git,README.md,vercel.json | Remove-Item -Recurse -Force
}

# 复制静态文件
Copy-Item -Path "$outputPath\*" -Destination $repoPath -Recurse -Force

# 4. 提交并推送到 GitHub
Write-Host "提交并推送更改到 GitHub..." -ForegroundColor Green
git add .
git commit -m "Update blog content $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
git push -u origin master

Write-Host "完成! 你的博客应该已经部署到 GitHub Pages。" -ForegroundColor Green
Write-Host "请访问 https://ch777777.github.io 查看你的博客。" -ForegroundColor Green 