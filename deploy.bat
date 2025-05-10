@echo off
echo 开始部署博客到 GitHub Pages...
echo.

set OUTPUT_PATH=%USERPROFILE%\halo-next\static
set REPO_PATH=D:\gerbok\ch777777.github.io
set JAVA_HOME=D:\gerbok\jdk-17.0.2
set PATH=%PATH%;%JAVA_HOME%\bin

echo 检查 Halo 是否已启动...
curl -s --head --connect-timeout 1 http://localhost:8090 > nul
if %ERRORLEVEL% NEQ 0 (
  echo Halo 未启动，正在启动...
  start /B java -jar D:\gerbok\choliy\halo-app\halo-2.20.11-SNAPSHOT.jar --spring.config.location=file:D:\gerbok\choliy\halo-app\application.yaml
  
  echo 等待 Halo 启动...
  ping -n 20 127.0.0.1 > nul
)

echo 创建输出目录...
if not exist "%OUTPUT_PATH%" mkdir "%OUTPUT_PATH%"
if not exist "%OUTPUT_PATH%\console" mkdir "%OUTPUT_PATH%\console"

echo 抓取首页...
curl -s -o "%OUTPUT_PATH%\index.html" http://localhost:8090

echo 将静态文件复制到 GitHub Pages 仓库...
cd /d %REPO_PATH%
for %%F in (*) do if not "%%F"==".git" if not "%%F"=="README.md" if not "%%F"=="vercel.json" del /q "%%F"
for /d %%D in (*) do if not "%%D"==".git" rmdir /s /q "%%D"

xcopy /e /y /q "%OUTPUT_PATH%\*" "%REPO_PATH%\"

echo 提交更改到 GitHub...
git add .
git commit -m "Update blog content %date% %time%"
git push -u origin master

echo 完成! 请访问 https://ch777777.github.io 查看你的博客。 