# FITIN License Manager

FITIN now uses server-validated installation licensing.

## Protection model

- A new installation shows the **Activate FITIN** screen.
- A license can allow one or multiple devices.
- License keys are stored on the server only as SHA-256 hashes.
- A successful activation receives a long random activation token bound to that installation ID.
- Protected `/api/*` endpoints require both the activation token and the installation ID.
- Licenses can expire or be revoked server-side.
- `/api/health`, `/api/license/activate`, and `/api/license/validate` remain public so activation can work.

This is substantially stronger than embedding a password/key inside the APK. No client-side licensing can make an APK impossible to reverse engineer; the important enforcement is therefore also done by the backend.

## Server setup

Set a strong secret in `backend/.env`:

    LICENSE_ADMIN_SECRET=<long random secret kept only on the server>

Use PostgreSQL in production and HTTPS for the public API.

## Create a license on the server

From the `backend` folder:

    python manage_licenses.py create --label "Customer 1" --devices 1

Optional expiry:

    python manage_licenses.py create --label "Annual license" --devices 1 --expires "2027-08-18T23:59:59+00:00"

The raw key is displayed once. Save it securely; the database stores only its hash.

List licenses:

    python manage_licenses.py list

Revoke a license:

    python manage_licenses.py revoke 3

## Android build

The project includes the complete Android configuration. The binary Gradle wrapper JAR is generated locally from the installed Flutter SDK so it does not need to be hand-maintained in this archive.

Windows PowerShell from `flutter`:

    .\bootstrap_android_wrapper.ps1
    .\build_fitin.ps1 -ApiBaseUrl "https://YOUR-DOMAIN/api"

For local Android emulator development only:

    .\build_fitin.ps1 -ApiBaseUrl "http://10.0.2.2:8000/api"

Before Play Store release, replace the temporary debug signing fallback in `android/app/build.gradle` with a private upload keystore and use an HTTPS API URL.
