# Pi Coding Agent · Docker Compose

使用 Docker Compose 和 Makefile 运行 [Pi Coding Agent](https://github.com/earendil-works/pi)，自动安装 [pi-provider-newapi](https://github.com/ttimasdf/pi-provider-newapi)，通过 NewAPI 自动发现、选择模型，无须手动维护模型列表。

Pi、Node.js 和相关工具运行在容器中；配置、会话和工作目录保存在宿主机。

## 环境要求

- Docker Engine 或 Docker Desktop
- Docker Compose v2
- GNU Make，以及支持 `id` 命令的 Shell 环境（如 Linux、macOS、WSL）

不依赖特定 Linux 发行版；容器基础镜像为 `node:24-trixie-slim`。

## 快速开始

在项目根目录执行：

```bash
make run
```

`make run` 会创建默认数据目录、按需构建镜像并启动 Pi。首次运行自动安装 `pi-provider-newapi`，退出后临时容器自动删除，持久化文件不受影响。

## 配置 NewAPI

在 Pi 内依次执行：

```text
/newapi-provider-add newapi
/login newapi
/model
```

填写 NewAPI 网关地址（如 `https://api.example.com`，不含 `/v1`）和 API Key，再选择模型。模型由插件自动发现；少数未知模型可能需要补充元数据。

如果模型错误使用 `/v1/responses` 并返回 404，而网关仅支持 `/v1/chat/completions`，在 `data/extension-settings/provider-newapi.json` 中对应 Provider 的配置对象内增加：

```json
"modelApiOverrides": {
  "^your-model-id$": "openai-completions"
}
```

替换为实际模型 ID（正则特殊字符需转义），保存后重启 Pi 并打开 `/model` 刷新模型目录。

## 常用命令

| 命令 | 说明 |
| --- | --- |
| `make run` | 按需构建并启动 Pi |
| `make build` | 构建镜像 |
| `make rebuild` | 无缓存重新构建 |
| `make update` | 更新基础镜像并重新构建 |
| `make shell` | 进入容器 root Shell |
| `make version` | 查看 Pi 版本 |
| `make config` | 检查 Compose 配置 |
| `make down` | 清理 Compose 资源 |

`make update` 不会清除 `data/` 中已安装的插件；插件更新需另行执行。

## 工作目录与数据

| 宿主机路径 | 容器路径 | 用途 |
| --- | --- | --- |
| `./data` | `/home/node/.pi/agent` | 配置、认证、插件和会话 |
| `./workspace` | `/workspace` | 默认工作目录 |

需要持久设置其他项目路径时，可将 `.env.example` 复制为 `.env`，并修改：

```dotenv
PI_WORKSPACE=/absolute/path/to/project
```

也可以临时指定：

```bash
PI_WORKSPACE=/absolute/path/to/project make run
```

`make run` 会将当前用户的 UID/GID 及附加用户组传入容器。启动时仅自动适配 `data/` 的所有权，不修改 `workspace`；Pi 对项目文件仍受该用户的权限约束。使用自定义工作目录前请确认路径存在。

`data/`、`workspace/` 和 `.env` 不应提交到 Git。只挂载允许 Pi 访问和修改的项目目录。

## 镜像与网络

Dockerfile 使用清华 TUNA Debian 镜像与 [npmmirror](https://npmmirror.com/) 加速安装，并预装 `git`、`ripgrep`、`fd` 等工具。如基础镜像拉取失败，请检查 Docker daemon 的网络和代理配置。

## 相关项目

- [Pi Coding Agent](https://github.com/earendil-works/pi)
- [pi-provider-newapi](https://github.com/ttimasdf/pi-provider-newapi)
