
# Diploma Project — Automated Deployment & Scaling on GCP

## Тема
Дослідження та реалізація підходів до автоматизованого розгортання і
масштабування високонавантажених сервісів у GCP.

## Три підходи до масштабування
| # | Підхід | Тригер | Файл |
|---|--------|--------|------|
| 1 | CPU-based HPA | CPU > 50% | k8s/hpa-cpu.yaml |
| 2 | RPS-based HPA (KEDA) | HTTP req/s > 50 | k8s/keda-rps.yaml |
| 3 | Queue-based HPA (KEDA) | Redis queue > 5 tasks | k8s/keda-queue.yaml |

## Структура проєкту
```
diploma/
├── app/                    # FastAPI застосунок
├── k8s/                    # Kubernetes маніфести
├── terraform/              # IaC (модулі: vpc, gke, redis)
├── scripts/                # Навантажувальне тестування (Locust)
├── monitoring/             # Prometheus + Grafana (Helm values)
└── .github/workflows/      # CI/CD pipelines
```

## Швидкий старт
1. Клонуй репо: `git clone https://github.com/sofa4578/diploma.git`
2. Додай секрет `GCP_CREDENTIALS` у GitHub → Settings → Secrets
3. Push у гілку `main` → автоматичний деплой запуститься
