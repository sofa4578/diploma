
"""
Скрипт для швидкого наповнення Redis-черги задачами.
Використовується для демонстрації підходу 3 (Queue-based HPA).

Запуск:
  python scripts/queue_producer.py --host http://<EXTERNAL_IP> --tasks 100
"""
import argparse
import time
import urllib.request
import urllib.error

def main():
    parser = argparse.ArgumentParser(description="Queue producer for approach 3 demo")
    parser.add_argument("--host", default="http://localhost:8000", help="API base URL")
    parser.add_argument("--tasks", type=int, default=50, help="Number of tasks to enqueue")
    parser.add_argument("--delay", type=float, default=0.05, help="Delay between requests (sec)")
    args = parser.parse_args()

    print(f"Sending {args.tasks} tasks to {args.host}/tasks ...")
    success = 0
    for i in range(args.tasks):
        url = f"{args.host}/tasks?payload=batch_task_{i}"
        try:
            req = urllib.request.Request(url, method="POST")
            with urllib.request.urlopen(req, timeout=5) as resp:
                if resp.status == 201:
                    success += 1
        except urllib.error.URLError as e:
            print(f"  [!] Task {i} failed: {e}")
        time.sleep(args.delay)

    print(f"Done. Enqueued {success}/{args.tasks} tasks.")
    print(f"Check queue length: curl {args.host}/tasks/length")

if __name__ == "__main__":
    main()
