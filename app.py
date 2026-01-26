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
        # Simulate an error but don't crash - return 500 instead
        print(f"Request #{request_count}: Simulating severe error (formerly crash)...", flush=True)
        return jsonify({
            "status": "error",
            "message": "Simulated severe error - but handled gracefully",
            "request_number": request_count
        }), 500
    
    elif failure_chance < 0.30:
        # Simulate an unhandled exception - will be caught by error handler
        print(f"Request #{request_count}: Simulating exception...", flush=True)
        raise RuntimeError("Simulated exception - handled by error handler")
    
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
    """Handle all unhandled exceptions gracefully"""
    import traceback
    # Log the error for debugging
    print(f"Exception handled: {type(e).__name__}: {str(e)}", flush=True)
    traceback.print_exc()
    
    return jsonify({
        "status": "error",
        "message": str(e),
        "type": type(e).__name__
    }), 500

# Add signal handlers for graceful shutdown
def handle_signal(signum, frame):
    """Handle termination signals gracefully"""
    print(f"Received signal {signum}, shutting down gracefully...", flush=True)
    sys.exit(0)

signal.signal(signal.SIGTERM, handle_signal)
signal.signal(signal.SIGINT, handle_signal)

# For gunicorn compatibility, expose the app object
# Remove the if __name__ == '__main__' block that runs Flask dev server
