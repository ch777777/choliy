# Halo 博客系统

这是基于 [Halo](https://github.com/halo-dev/halo) 项目的个人博客部署，Halo 是一款现代化的开源博客/CMS系统，使用 Java 开发。

## 项目结构

- `halo-app/`: Halo 应用程序目录
  - `halo-2.20.11-SNAPSHOT.jar`: Halo 应用程序 JAR 包
  - `application.yaml`: Halo 配置文件

## 如何运行

1. 确保你的系统已安装 JDK 17 或更高版本
2. 进入 `halo-app` 目录
3. 使用以下命令启动应用：

```bash
java -jar halo-2.20.11-SNAPSHOT.jar --spring.config.location=file:./application.yaml
```

4. 启动后，访问 `http://localhost:8090` 打开 Halo 博客
5. 使用配置文件中设置的管理员账号密码登录（默认：admin/admin）

## 配置说明

可以在 `application.yaml` 文件中修改以下配置：

- 端口：`server.port`
- 工作目录：`halo.work-dir`
- 外部访问地址：`halo.external-url`
- 数据库配置：`spring.datasource.*`
- 管理员账号：`halo.security.initializer.master-username`
- 管理员密码：`halo.security.initializer.master-password`

## 更多资源

- [Halo 官方文档](https://docs.halo.run/)
- [Halo 官方主题](https://halo.run/themes)
- [Halo 官方插件](https://halo.run/plugins) 