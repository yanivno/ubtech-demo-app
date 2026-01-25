# Flask Test Application

A simple Flask application with multiple endpoints for testing Kubernetes deployments.

## Application Behavior

- **`/`** - Home endpoint, always returns success
- **`/health`** - Health check endpoint for liveness probe
- **`/ready`** - Readiness check endpoint
- **`/test`** - Test endpoint that returns success with request count

## Local Development

### Run locally with Python:
```bash
pip install -r requirements.txt
python app.py
```

### Run locally with Docker:
```bash
docker build -t flask-crash-app:latest .
docker run -p 5000:5000 flask-crash-app:latest
```

## Kubernetes Deployment

### Build and deploy:
```bash
# Build the Docker image
docker build -t flask-crash-app:latest .

# If using minikube, load the image:
# minikube image load flask-crash-app:latest

# If using kind, load the image:
# kind load docker-image flask-crash-app:latest

# Deploy to Kubernetes
kubectl apply -f k8s/

# Check deployment status
kubectl get pods -l app=flask-crash-app
kubectl get svc flask-crash-app
```

### Test the application:
```bash
# Get the service URL (for minikube)
# minikube service flask-crash-app --url

# Or port-forward
kubectl port-forward svc/flask-crash-app 8080:80

# Test endpoints
curl http://localhost:8080/
curl http://localhost:8080/health
curl http://localhost:8080/test
```

### Monitor the application:
```bash
# Watch pod status
kubectl get pods -l app=flask-crash-app -w

# View logs
kubectl logs -l app=flask-crash-app -f
```

## Testing the Application

Run multiple test requests to verify stable behavior:
```bash
for i in {1..20}; do
  echo "Request $i:"
  curl -s http://localhost:8080/test
  echo ""
  sleep 1
done
```

The application should handle all requests successfully without crashing.
