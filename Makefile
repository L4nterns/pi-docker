.DEFAULT_GOAL := help

COMPOSE := docker compose
PUID := $(shell id -u)
PGID := $(shell id -g)
PI_GROUPS := $(shell id -G | tr ' ' ',')
export PUID PGID PI_GROUPS

.PHONY: help prepare run build rebuild update shell version config down

help:
	@echo "Pi Docker Commands"
	@echo "  make run      构建（如有需要）并启动 Pi"
	@echo "  make build    构建镜像"
	@echo "  make rebuild  无缓存重新构建"
	@echo "  make update   拉取最新基础镜像并重新构建"
	@echo "  make shell    进入临时容器 root Shell"
	@echo "  make version  查看 Pi 版本"
	@echo "  make config   验证 Compose 配置"
	@echo "  make down     清理 Compose 资源"

prepare:
	@mkdir -p -- ./data ./workspace

run: prepare
	@$(COMPOSE) run --build --rm pi

build:
	@$(COMPOSE) build pi

rebuild:
	@$(COMPOSE) build --no-cache pi

update:
	@$(COMPOSE) build --pull --no-cache pi

shell: prepare
	@$(COMPOSE) run --build --rm --entrypoint bash pi

version: prepare
	@$(COMPOSE) run --build --rm pi --version

config:
	@$(COMPOSE) config

down:
	@$(COMPOSE) down
