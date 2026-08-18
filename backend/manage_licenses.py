import argparse
from datetime import datetime, timezone
from sqlalchemy import select
from app.db import Base, SessionLocal, engine
from app.license_service import create_license
from app.models.license import License, LicenseActivation


def parse_date(value):
    if not value:
        return None
    dt = datetime.fromisoformat(value.replace('Z', '+00:00'))
    return dt if dt.tzinfo else dt.replace(tzinfo=timezone.utc)


def main():
    parser = argparse.ArgumentParser(description='FITIN license manager')
    sub = parser.add_subparsers(dest='command', required=True)
    c = sub.add_parser('create')
    c.add_argument('--label', default='FITIN license')
    c.add_argument('--devices', type=int, default=1)
    c.add_argument('--expires', help='ISO date/time, e.g. 2027-12-31T23:59:59+00:00')
    sub.add_parser('list')
    r = sub.add_parser('revoke')
    r.add_argument('id', type=int)
    args = parser.parse_args()

    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        if args.command == 'create':
            lic, key = create_license(db, args.label, args.devices, parse_date(args.expires))
            print(f'ID: {lic.id}')
            print(f'LICENSE KEY: {key}')
            print('Save this key now. Only its hash is stored in the database.')
        elif args.command == 'list':
            for lic in db.scalars(select(License).order_by(License.id.desc())).all():
                active = len(db.scalars(select(LicenseActivation).where(
                    LicenseActivation.license_id == lic.id,
                    LicenseActivation.is_active.is_(True),
                )).all())
                print(f'{lic.id}: {lic.label} | ...{lic.key_hint} | active={lic.is_active} | devices={active}/{lic.max_devices} | expires={lic.expires_at}')
        else:
            lic = db.get(License, args.id)
            if not lic:
                raise SystemExit('License not found')
            lic.is_active = False
            for a in db.scalars(select(LicenseActivation).where(LicenseActivation.license_id == lic.id)).all():
                a.is_active = False
            db.commit()
            print(f'Revoked license {lic.id}')
    finally:
        db.close()


if __name__ == '__main__':
    main()
