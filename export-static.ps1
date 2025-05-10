$outputPath = "$env:USERPROFILE\halo-next\static"
$repoPath = "D:\gerbok\username.github.io"  # 请将 username 替换为你的 GitHub 用户名

# 1. 确保 Halo 已经在运行
Write-Host "请确保 Halo 已经启动并运行在 http://localhost:8090" -ForegroundColor Yellow
$response = Read-Host "Halo 是否已启动? (y/n)"
if ($response -ne "y") {
    Write-Host "请先启动 Halo 再运行此脚本" -ForegroundColor Red
    exit
}

# 2. 使用 wget 抓取静态页面
Write-Host "开始抓取静态页面..." -ForegroundColor Green
if (!(Test-Path -Path $outputPath)) {
    New-Item -Path $outputPath -ItemType Directory -Force
}

# 安装 wget 如果未安装
if (!(Get-Command wget -ErrorAction SilentlyContinue)) {
    # 使用 PowerShell 内置的 Invoke-WebRequest 替代
    Write-Host "使用 PowerShell 抓取网站..." -ForegroundColor Cyan
    
    # 创建输出目录
    New-Item -Path "$outputPath\console" -ItemType Directory -Force
    
    # 抓取首页
    Invoke-WebRequest -Uri "http://localhost:8090" -OutFile "$outputPath\index.html"
    
    # 抓取CSS和JS资源
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
} else {
    # 使用 wget 抓取
    wget -r -np -k -p -E http://localhost:8090 -P $outputPath
}

# 3. 复制静态文件到 GitHub Pages 仓库
Write-Host "将静态文件复制到 GitHub Pages 仓库..." -ForegroundColor Green
if (!(Test-Path -Path $repoPath)) {
    New-Item -Path $repoPath -ItemType Directory -Force
    Set-Location $repoPath
    git init
    git remote add origin "https://github.com/ch777777/ch777777.github.io.git"  # 请替换为你的仓库URL
} else {
    Set-Location $repoPath
    # 清空仓库，但保留 .git 目录
    Get-ChildItem -Path $repoPath -Exclude .git | Remove-Item -Recurse -Force
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