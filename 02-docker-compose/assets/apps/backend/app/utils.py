import hashlib
import base64
from urllib.parse import urlparse

def is_valid_url(url: str) -> bool:
    """
    Validate if the provided string is a valid URL.
    """
    try:
        result = urlparse(url)
        return all([result.scheme, result.netloc])
    except Exception:
        return False

def generate_short_code(url: str, length: int = 6) -> str:
    """
    Generate a short code from the URL using SHA-256 hash.
    Returns a base64-encoded string of specified length.
    """
    hash_object = hashlib.sha256(url.encode())
    hash_digest = hash_object.digest()
    base64_encoded = base64.urlsafe_b64encode(hash_digest).decode('utf-8')
    return base64_encoded[:length].rstrip('=')
