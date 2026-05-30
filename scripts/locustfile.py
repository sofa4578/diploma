
"""
Навантажувальне тестування для всіх трьох підходів.

Запуск (Web UI):
  locust -f scripts/locustfile.py --host http://<EXTERNAL_IP>

Запуск (headless, для скриншотів у диплом):
  locust -f scripts/locustfile.py --headless \
    --host http://<EXTERNAL_IP> \
    -u 300 -r 30 --run-time 5m \
    --html locust_report/report.html

Сценарії:
  - LightUser:  тільки GET /items, /  — легке навантаження (підхід 1, 2)
  - HeavyUser:  GET /stress           — CPU-важке (підхід 1)
  - QueueUser:  POST /tasks           — заповнює чергу (підхід 3)
"""
from locust import HttpUser, task, between, constant


class LightUser(HttpUser):
    """Симулює звичайного користувача — GET запити."""
    weight = 6
    wait_time = between(0.5, 1.5)

    @task(4)
    def get_item(self):
        item_id = str(__import__("random").randint(1, 500))
        with self.client.get(f"/items/{item_id}", catch_response=True) as r:
            if r.status_code not in (200, 404):
                r.failure(f"Unexpected status: {r.status_code}")

    @task(3)
    def list_items(self):
        page = __import__("random").randint(0, 20)
        self.client.get(f"/items?skip={page * 20}&limit=20")

    @task(2)
    def root(self):
        self.client.get("/")

    @task(1)
    def stats(self):
        self.client.get("/stats")


class HeavyUser(HttpUser):
    weight = 2
    wait_time = between(2, 5)        # було between(1,3) — рідше запитуємо

    @task
    def stress(self):
        n = __import__("random").choice([200000, 300000])  # менші значення
        self.client.get(f"/stress?n={n}", timeout=60)      # більший timeout


class QueueUser(HttpUser):
    """Заповнює чергу задач — для підходу 3 (Queue HPA)."""
    weight = 2
    wait_time = constant(0.2)   # Швидко наповнюємо чергу

    @task(3)
    def enqueue(self):
        task_num = __import__("random").randint(1, 1000)
        self.client.post(f"/tasks?payload=task_{task_num}")

    @task(1)
    def check_queue(self):
        self.client.get("/tasks/length")
