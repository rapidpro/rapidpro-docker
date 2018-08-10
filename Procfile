web: /venv/bin/uwsgi --http-auto-chunked --http-keepalive
worker: /venv/bin/celery --beat --app=temba worker --loglevel=INFO --queues=celery,msgs,flows,handler
