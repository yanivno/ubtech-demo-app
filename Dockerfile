FROM python:3.11-slim

WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app.py .

# Create non-root user for security
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

# Expose port
EXPOSE 5000

# Run the application with gunicorn (production WSGI server)
# --bind 0.0.0.0:5000 - Listen on all interfaces, port 5000
# --workers 4 - Use 4 worker processes for handling requests
# --timeout 30 - 30 second timeout for requests
# --graceful-timeout 30 - 30 seconds for graceful shutdown
# --access-logfile - - Log access to stdout
# --error-logfile - - Log errors to stdout
# app:app - Module name:application variable
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "4", "--timeout", "30", "--graceful-timeout", "30", "--access-logfile", "-", "--error-logfile", "-", "app:app"]
