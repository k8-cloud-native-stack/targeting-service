# ---- build ----
FROM python:3.11-slim AS build
WORKDIR /install
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install/deps -r requirements.txt

# ---- runtime ----
FROM python:3.11-slim
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PORT=8003
RUN useradd --system --no-create-home --uid 10001 app
WORKDIR /app
COPY --from=build /install/deps /usr/local
COPY --chown=app:app . .
USER 10001
EXPOSE 8003
CMD ["sh", "-c", "exec gunicorn --bind 0.0.0.0:${PORT} --workers 2 --access-logfile - app:app"]
