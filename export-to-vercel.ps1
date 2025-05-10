$outputPath = "$env:USERPROFILE\halo-next\static"
$vercelProjectPath = "D:\gerbok\ch777777-vercel"  # Vercel 项目路径

# 1. 确保 Halo 已经在运行
Write-Host "请确保 Halo 已经启动并运行在 http://localhost:8090" -ForegroundColor Yellow
$response = Read-Host "Halo 是否已启动? (y/n)"
if ($response -ne "y") {
    Write-Host "请先启动 Halo 再运行此脚本" -ForegroundColor Red
    exit
}

# 2. 使用 PowerShell 抓取静态页面
Write-Host "开始抓取静态页面..." -ForegroundColor Green
if (!(Test-Path -Path $outputPath)) {
    New-Item -Path $outputPath -ItemType Directory -Force
}

# 使用 PowerShell 内置的 Invoke-WebRequest 抓取
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

# 3. 准备 Vercel 项目
Write-Host "准备 Vercel 项目..." -ForegroundColor Green
if (!(Test-Path -Path $vercelProjectPath)) {
    New-Item -Path $vercelProjectPath -ItemType Directory -Force
    Set-Location $vercelProjectPath
    git init
} else {
    Set-Location $vercelProjectPath
    # 清空仓库，但保留 .git 目录
    Get-ChildItem -Path $vercelProjectPath -Exclude .git | Remove-Item -Recurse -Force
}

# 复制静态文件
Copy-Item -Path "$outputPath\*" -Destination $vercelProjectPath -Recurse -Force

# 创建 vercel.json 配置文件
@"
{
  "version": 2,
  "builds": [
    {
      "src": "**/*",
      "use": "@vercel/static"
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "/$1"
    }
  ]
}
"@ | Out-File -FilePath "$vercelProjectPath\vercel.json" -Encoding utf8

# 4. 提交代码
Write-Host "提交代码..." -ForegroundColor Green
git add .
git commit -m "Update blog content $(Get-Date -Format 'yyyy-MM-dd HH:mm')"

# 5. 指导如何部署到 Vercel
Write-Host "代码已提交。请按照以下步骤部署到 Vercel:" -ForegroundColor Green
Write-Host "1. 访问 https://vercel.com 并登录" -ForegroundColor Cyan
Write-Host "2. 创建新项目，选择从现有代码导入" -ForegroundColor Cyan
Write-Host "3. 连接你的 GitHub 账户并选择仓库" -ForegroundColor Cyan
Write-Host "4. 部署完成后，Vercel 会提供一个 URL" -ForegroundColor Cyan
Write-Host "完成！" -ForegroundColor Green 