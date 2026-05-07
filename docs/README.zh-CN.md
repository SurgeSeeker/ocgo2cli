# ocgo2cli

[English](../README.md) | [中文](README.zh-CN.md)

将 [OpenCode Go](https://opencode.ai) 订阅转换为标准 Anthropic Messages API，供 [Claude Code](https://github.com/anthropics/claude-code) / [Codex](https://github.com/openai/codex)（TODO）使用。

```
OpenCode Go 订阅             ocgo2cli                    Claude Code
        │                        │                            │
        │  POST /v1/chat/completions（OpenAI 格式）         │
        │                        │                            │
        │                        │  POST /v1/messages         │
        │                        │  {"model":"claude-sonnet-4"}│
        │                        │  ◄───────────────────────  │
        │  ◄──────────────────── │                            │
        │                        │  ────────────────────────► │
        │                        │  （Anthropic 格式）        │
```

**严格 1:1 模型映射。无场景检测，无回退链，无中途切换。** 就是一份 JSON 配置把 Claude 模型名指向后端模型。

## 配置示例

DeepSeek V4 Pro 负责复杂任务（sonnet + opus），DeepSeek V4 Flash 负责轻量任务（haiku）：

```json
{
  "listen": "127.0.0.1:3457",
  "opencode_base_url": "https://opencode.ai/zen/go/v1/chat/completions",
  "opencode_anthropic_base_url": "https://opencode.ai/zen/go/v1/messages",
  "api_key": "${OC_API_KEY}",
  "models": {
    "claude-sonnet-4-20250514": {
      "model_id": "deepseek-v4-pro",
      "temperature": 0.7,
      "max_tokens": 8192,
      "reasoning_effort": "max",
      "thinking": {"type": "enabled"}
    },
    "claude-opus-4-6-20250514": {
      "model_id": "deepseek-v4-pro",
      "temperature": 0.7,
      "max_tokens": 16384
    },
    "claude-haiku-4-5-20250514": {
      "model_id": "deepseek-v4-flash",
      "temperature": 0.5,
      "max_tokens": 4096
    }
  }
}
```

## 快速开始

```bash
git clone git@github.com:SurgeSeeker/ocgo2cli.git
cd ocgo2cli
make build

# 创建配置
mkdir -p ~/.config/ocgo2cli
cp config.example.json ~/.config/ocgo2cli/config.json
# 编辑 config.json，填入 API key

# 运行
./bin/ocgo2cli run        # 前台（调试用）
./bin/ocgo2cli start      # 后台守护进程
```

### Claude Code 接入

```json
// ~/.claude/settings.json
{
  "env": {
    "ANTHROPIC_BASE_URL": "http://127.0.0.1:3457"
  }
}
```

> 注意：Claude Code 必须通过 `settings.json` → `env` 配置 `ANTHROPIC_BASE_URL`。shell 环境变量不生效。

## 守护进程管理

```bash
ocgo2cli start     # 启动
ocgo2cli stop      # 停止
ocgo2cli restart   # 重启
ocgo2cli status    # 查看状态
ocgo2cli install   # 安装为用户级服务（免 sudo）
ocgo2cli uninstall # 移除服务
```

跨平台：Linux systemd / macOS launchd / Windows SCM。

## 配置参考

| 字段 | 说明 |
|------|------|
| `listen` | 监听地址（默认 `127.0.0.1:3457`） |
| `opencode_base_url` | OpenAI 兼容端点 |
| `opencode_anthropic_base_url` | Anthropic 原生端点（MiniMax 直通） |
| `api_key` | API 密钥，支持 `${ENV}` 插值 |
| `models.<name>.model_id` | 后端模型 ID |
| `models.<name>.temperature` | 覆盖温度 |
| `models.<name>.max_tokens` | 覆盖最大 token 数 |
| `models.<name>.reasoning_effort` | 推理深度（DeepSeek thinking 模式） |
| `models.<name>.thinking` | thinking 开关：`{"type":"enabled"}` / `{"type":"disabled"}` |

## 功能

- **Anthropic ↔ OpenAI 格式转换** — 完整类型保真，thinking/reasoning_content 双向通
- **Anthropic 原生模型直通** — MiniMax M2.5/M2.7 零转换转发
- **SSE 流式** — 实时流式，reasoning / text 块正确切换
- **`${ENV}` 插值** — API key 不入仓库
- **跨平台守护进程** — kardianos/service，用户级，免 root

## 构建与测试

```bash
make build    # 构建 → bin/ocgo2cli
make test     # 测试（含竞态检测）
make lint     # go vet
make clean    # 清理
```

## 文档

- [English README](../README.md)
- [CLAUDE.md](../CLAUDE.md) — 项目架构（面向 Claude Code）

## 致谢

格式转换基于 [oc-go-cc](https://github.com/nousresearch/oc-go-cc)（Nous Research）。

## 许可证

GNU Affero General Public License v3.0 — 详见 [LICENSE](../LICENSE)。
