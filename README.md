# Halo 博客系统

这是基于 [Halo](https://github.com/halo-dev/halo) 项目的个人博客部署，Halo 是一款现代化的开源博客/CMS系统，使用 Java 开发。

## 项目结构

- `halo-app/`: Halo 应用程序目录
  - `halo-2.20.11-SNAPSHOT.jar`: Halo 应用程序 JAR 包
  - `application.yaml`: Halo 配置文件
- `export-static.ps1`: 静态页面导出脚本，用于无服务器部署

## 如何运行

1. 确保你的系统已安装 JDK 17 或更高版本
2. 进入 `halo-app` 目录
3. 使用以下命令启动应用：

```bash
java -jar halo-2.20.11-SNAPSHOT.jar --spring.config.location=file:./application.yaml
```

4. 启动后，访问 `http://localhost:8090` 打开 Halo 博客
5. 使用配置文件中设置的管理员账号密码登录（默认：admin/admin）

## 无服务器部署方式

本项目提供了无服务器部署方案，可以将博客内容静态化并部署到 GitHub Pages：

1. 先运行 Halo 博客系统
2. 创建 GitHub 仓库：`username.github.io`（将 username 替换为你的 GitHub 用户名）
3. 修改 `export-static.ps1` 脚本中的仓库路径
4. 运行脚本：`.\export-static.ps1`
5. 访问 `https://username.github.io` 查看静态博客

### GitHub Pages 仓库

静态博客部署在 [ch777777.github.io](https://github.com/ch777777/ch777777.github.io) 仓库中。

## 配置说明

可以在 `application.yaml` 文件中修改以下配置：

- 端口：`server.port`
- 工作目录：`halo.work-dir`
- 外部访问地址：`halo.external-url`
- 数据库配置：`spring.datasource.*`
- 管理员账号：`halo.security.initializer.master-username`
- 管理员密码：`halo.security.initializer.master-password`
- 静态文件路径：`halo.theme.static-path`

## 更多资源

- [Halo 官方文档](https://docs.halo.run/)
- [Halo 官方主题](https://halo.run/themes)
- [Halo 官方插件](https://halo.run/plugins) 