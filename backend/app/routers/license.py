from datetime import datetime
import secrets
from fastapi import APIRouter, Depends, Header, HTTPException
from pydantic import BaseModel, Field
from sqlalchemy import select
from sqlalchemy.orm import Session
from app.config import settings
from app.db import get_db
from app.license_service import activate_license, create_license, validate_activation
from app.models.license import License, LicenseActivation

router = APIRouter(prefix='/license', tags=['License'])


class ActivateRequest(BaseModel):
    license_key: str = Field(min_length=8, max_length=128)
    device_id: str = Field(min_length=16, max_length=200)


class ValidateRequest(BaseModel):
    device_id: str = Field(min_length=16, max_length=200)


class CreateLicenseRequest(BaseModel):
    label: str = 'FITIN license'
    max_devices: int = Field(default=1, ge=1, le=100)
    expires_at: datetime | None = None


def require_admin_secret(x_fitin_admin_secret: str | None = Header(default=None)):
    if not settings.license_admin_secret:
        raise HTTPException(503, 'LICENSE_ADMIN_SECRET is not configured on the server.')
    if not x_fitin_admin_secret or not secrets.compare_digest(x_fitin_admin_secret, settings.license_admin_secret):
        raise HTTPException(401, 'Invalid admin secret.')


@router.post('/activate')
def activate(payload: ActivateRequest, db: Session = Depends(get_db)):
    token, error = activate_license(db, payload.license_key, payload.device_id)
    if error:
        raise HTTPException(403, error)
    return {'success': True, 'data': {'activation_token': token}}


@router.post('/validate')
def validate(
    payload: ValidateRequest,
    x_fitin_license_token: str | None = Header(default=None),
    db: Session = Depends(get_db),
):
    if not x_fitin_license_token:
        raise HTTPException(401, 'Missing activation token.')
    lic = validate_activation(db, x_fitin_license_token, payload.device_id)
    if not lic:
        raise HTTPException(403, 'License activation is not valid.')
    return {'success': True, 'data': {'valid': True, 'expires_at': lic.expires_at}}


@router.post('/admin/create', dependencies=[Depends(require_admin_secret)])
def admin_create(payload: CreateLicenseRequest, db: Session = Depends(get_db)):
    lic, raw_key = create_license(db, payload.label, payload.max_devices, payload.expires_at)
    return {
        'success': True,
        'data': {
            'id': lic.id,
            'license_key': raw_key,
            'label': lic.label,
            'max_devices': lic.max_devices,
            'expires_at': lic.expires_at,
        },
    }


@router.get('/admin/list', dependencies=[Depends(require_admin_secret)])
def admin_list(db: Session = Depends(get_db)):
    items = []
    for lic in db.scalars(select(License).order_by(License.id.desc())).all():
        active_count = len(db.scalars(select(LicenseActivation).where(
            LicenseActivation.license_id == lic.id,
            LicenseActivation.is_active.is_(True),
        )).all())
        items.append({
            'id': lic.id,
            'label': lic.label,
            'key_hint': lic.key_hint,
            'is_active': lic.is_active,
            'max_devices': lic.max_devices,
            'active_devices': active_count,
            'expires_at': lic.expires_at,
            'created_at': lic.created_at,
        })
    return {'success': True, 'data': {'items': items}}


@router.post('/admin/{license_id}/revoke', dependencies=[Depends(require_admin_secret)])
def admin_revoke(license_id: int, db: Session = Depends(get_db)):
    lic = db.get(License, license_id)
    if not lic:
        raise HTTPException(404, 'License not found.')
    lic.is_active = False
    for activation in db.scalars(select(LicenseActivation).where(LicenseActivation.license_id == lic.id)).all():
        activation.is_active = False
    db.commit()
    return {'success': True, 'data': {'revoked': license_id}}
