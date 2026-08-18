import hashlib
import secrets
from datetime import datetime, timezone
from sqlalchemy import select
from sqlalchemy.orm import Session
from app.models.license import License, LicenseActivation


def _hash(value: str) -> str:
    return hashlib.sha256(value.encode('utf-8')).hexdigest()


def normalize_key(value: str) -> str:
    return value.strip().upper().replace(' ', '')


def generate_license_key() -> str:
    parts = [secrets.token_hex(3).upper() for _ in range(4)]
    return 'FITIN-' + '-'.join(parts)


def is_expired(license_obj: License) -> bool:
    if license_obj.expires_at is None:
        return False
    expires = license_obj.expires_at
    if expires.tzinfo is None:
        expires = expires.replace(tzinfo=timezone.utc)
    return expires <= datetime.now(timezone.utc)


def create_license(db: Session, label: str, max_devices: int, expires_at=None):
    raw_key = generate_license_key()
    lic = License(
        label=label.strip() or 'FITIN license',
        key_hash=_hash(normalize_key(raw_key)),
        key_hint=raw_key[-8:],
        max_devices=max(1, max_devices),
        expires_at=expires_at,
        is_active=True,
    )
    db.add(lic)
    db.commit()
    db.refresh(lic)
    return lic, raw_key


def activate_license(db: Session, raw_key: str, device_id: str):
    key_hash = _hash(normalize_key(raw_key))
    device_hash = _hash(device_id.strip())
    lic = db.scalar(select(License).where(License.key_hash == key_hash))
    if not lic or not lic.is_active or is_expired(lic):
        return None, 'Invalid, expired, or revoked license.'

    existing = db.scalar(
        select(LicenseActivation).where(
            LicenseActivation.license_id == lic.id,
            LicenseActivation.device_hash == device_hash,
            LicenseActivation.is_active.is_(True),
        )
    )
    if existing:
        existing.is_active = False

    active_devices = list(db.scalars(
        select(LicenseActivation).where(
            LicenseActivation.license_id == lic.id,
            LicenseActivation.is_active.is_(True),
        )
    ).all())
    if len(active_devices) >= lic.max_devices:
        db.rollback()
        return None, 'This license has reached its device limit.'

    token = secrets.token_urlsafe(48)
    activation = LicenseActivation(
        license_id=lic.id,
        device_hash=device_hash,
        token_hash=_hash(token),
        is_active=True,
    )
    db.add(activation)
    db.commit()
    return token, None


def validate_activation(db: Session, token: str, device_id: str, touch: bool = True):
    activation = db.scalar(
        select(LicenseActivation).where(
            LicenseActivation.token_hash == _hash(token.strip()),
            LicenseActivation.device_hash == _hash(device_id.strip()),
            LicenseActivation.is_active.is_(True),
        )
    )
    if not activation:
        return None
    lic = db.get(License, activation.license_id)
    if not lic or not lic.is_active or is_expired(lic):
        return None
    if touch:
        activation.last_seen_at = datetime.now(timezone.utc)
        db.commit()
    return lic
