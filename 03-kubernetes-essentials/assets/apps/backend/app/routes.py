from flask import Blueprint, request, jsonify, redirect, current_app
from app.utils import generate_short_code, is_valid_url
import uuid

bp = Blueprint('main', __name__)

@bp.route('/ping', methods=['GET'])
def ping():
    """
    Simple ping endpoint to check if the server is running.
    """
    return jsonify({'message': 'pong'}), 200

@bp.route('/health', methods=['GET'])
def health_check():
    """
    Health check endpoint.
    """
    try:
        current_app.redis_client.ping()
        return jsonify({'status': 'healthy', 'redis': 'connected'}), 200
    except Exception as e:
        return jsonify({'status': 'unhealthy', 'error': str(e)}), 503

@bp.route('/shorten', methods=['POST'])
def shorten_url():
    """
    Create a shortened URL.
    Expects JSON body with 'url' field.
    """
    data = request.get_json()

    if not data or 'url' not in data:
        return jsonify({'error': 'URL is required'}), 400

    original_url = data['url'].strip()

    if not is_valid_url(original_url):
        return jsonify({'error': 'Invalid URL format'}), 400

    # Check if URL already exists in Redis
    existing_code = current_app.redis_client.get(f"url:{original_url}")
    if existing_code:
        base_url = request.host_url.rstrip('/')
        return jsonify({
            'short_url': f"{base_url}/{existing_code}",
            'short_code': existing_code,
            'original_url': original_url
        }), 200

    # Generate short code
    short_code = generate_short_code(original_url)

    # Handle collisions by appending UUID suffix
    attempt = 0
    max_attempts = 5
    while current_app.redis_client.exists(f"code:{short_code}") and attempt < max_attempts:
        short_code = generate_short_code(original_url + str(uuid.uuid4()))
        attempt += 1

    if attempt >= max_attempts:
        return jsonify({'error': 'Failed to generate unique short code'}), 500

    # Store in Redis with bidirectional mapping
    current_app.redis_client.set(f"code:{short_code}", original_url)
    current_app.redis_client.set(f"url:{original_url}", short_code)

    # Optional: Set expiration (e.g., 30 days)
    current_app.redis_client.expire(f"code:{short_code}", 2592000)
    current_app.redis_client.expire(f"url:{original_url}", 2592000)

    base_url = request.host_url.rstrip('/')

    return jsonify({
        'short_url': f"{base_url}/{short_code}",
        'short_code': short_code,
        'original_url': original_url
    }), 201

@bp.route('/<short_code>', methods=['GET'])
def redirect_to_original(short_code):
    """
    Redirect to the original URL based on short code.
    """
    if not short_code or len(short_code) > 20:
        return jsonify({'error': 'Invalid short code'}), 400

    original_url = current_app.redis_client.get(f"code:{short_code}")

    if not original_url:
        return jsonify({'error': 'Short URL not found'}), 404

    return redirect(original_url, code=302)

@bp.route('/stats/<short_code>', methods=['GET'])
def get_stats(short_code):
    """
    Get statistics for a short code (optional feature).
    """
    original_url = current_app.redis_client.get(f"code:{short_code}")

    if not original_url:
        return jsonify({'error': 'Short URL not found'}), 404

    ttl = current_app.redis_client.ttl(f"code:{short_code}")

    return jsonify({
        'short_code': short_code,
        'original_url': original_url,
        'ttl_seconds': ttl if ttl > 0 else None
    }), 200
