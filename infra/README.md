# AI 课堂后台本地部署

本目录用于 P0 后台管理系统的本地 Docker Compose 部署。

```bash
cd infra
docker compose up --build
```

默认入口：

- 后台管理：`http://localhost`
- 后端 API：`http://localhost/api/v1`
- Spring Boot 健康检查：`http://localhost/actuator/health`
- MinIO Console：`http://localhost:9001`

当前 P0 使用本地固定验证码 `123456`，生产前必须替换为真实短信服务和更安全的 JWT 密钥。
