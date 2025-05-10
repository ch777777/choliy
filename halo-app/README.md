# Halo 应用程序 JAR 文件

由于 GitHub 文件大小限制，Halo 的 JAR 文件没有包含在此仓库中。

## 如何获取 Halo JAR 文件

有以下几种方式获取 Halo JAR 文件：

### 方法一：从官方仓库下载

1. 访问 Halo 官方仓库 Releases 页面：https://github.com/halo-dev/halo/releases
2. 下载最新版本的 JAR 文件
3. 将下载好的 JAR 文件放到此目录下

### 方法二：自行构建

1. 克隆 Halo 仓库：`git clone https://github.com/halo-dev/halo.git`
2. 进入 Halo 目录：`cd halo`
3. 使用 Gradle 构建：`./gradlew clean build -x test`
4. 构建完成后，JAR 文件位于 `application/build/libs/` 目录

获取 JAR 文件后，将其重命名为 `halo-2.20.11-SNAPSHOT.jar` 并放置在当前目录下即可使用。 