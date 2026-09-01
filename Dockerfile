FROM python:3.12-slim

# Security: don't run the application as root
RUN useradd --create-home --shell /usr/sbin/nologin appuser

WORKDIR /app

# Copy dependency file first for Docker layer caching
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy only the application
COPY app.py .

# Give the non-root user ownership
RUN chown -R appuser:appuser /app

# Switch away from root
USER appuser

EXPOSE 8080

# Container health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/health')" || exit 1

CMD ["python", "app.py"]