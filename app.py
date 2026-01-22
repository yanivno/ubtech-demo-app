import os
import random
import signal
import sys
from flask import Flask, jsonify

app = Flask(__name__)

# Track request count for deterministic failures
request_count = 0

@app.route('/')
def home():
    return jsonify({
        "status": "healthy",
        "message": "Welcome to the Flask test application"
    })

@app.route('/health')
def health():
    return jsonify({"status": "healthy"}), 200

@app.route('/ready')
def ready():
    return jsonify({"status": "ready"}), 200

@app.route('/test')
def test():
    global request_count
    request_count += 1
    
    # Random failure simulation - approximately 30% chance of failure
    failure_chance = random.random()
    
    if failure_chance < 0.15:
        # Simulate a crash - exit the process
        print(f"Request #{request_count}: CRASH! Application terminating...", flush=True)
        sys.stdout.flush()
        os._exit(1)  # Force exit to simulate crash
    
    elif failure_chance < 0.30:
        # Simulate an unhandled exception
        print(f"Request #{request_count}: Unhandled exception occurring...", flush=True)
        raise RuntimeError("Simulated unhandled exception - application unstable!")
    
    else:
        # Success case
        print(f"Request #{request_count}: Success!", flush=True)
        return jsonify({
            "status": "success",
            "message": "Test completed successfully",
            "request_number": request_count
        }), 200

@app.errorhandler(Exception)
def handle_exception(e):
    return jsonify({
        "status": "error",
        "message": str(e)
    }), 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    print(f"Starting Flask application on port {port}...", flush=True)
    app.run(host='0.0.0.0', port=port, debug=False)
