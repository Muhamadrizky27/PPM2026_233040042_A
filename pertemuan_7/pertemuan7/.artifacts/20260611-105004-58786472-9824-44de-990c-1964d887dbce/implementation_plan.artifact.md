# Implementation Plan - Transition to REST API (Pertemuan 5)

This plan outlines the transition of the "Catatan Mahasiswa" application from local SQLite storage to a remote REST API as per the Pertemuan 5 requirements.

## User Review Required

> [!IMPORTANT]
> This transition replaces local persistence with a remote server. Data will now be shared across devices but requires an internet connection.

## Proposed Changes

### Dependencies

#### [pubspec.yaml](file:///D:/PPM_233040042_A/pertemuan_6/pertemuan6/pubspec.yaml)

- Add `http: ^1.2.0` dependency.
- Remove `sqflite` and `path` dependencies as they are no longer needed.

---

### Data Model

#### [catatan.dart](file:///D:/PPM_233040042_A/pertemuan_6/pertemuan6/lib/catatan.dart)

- Replace `toMap()` and `fromMap()` with `toJson()` and `fromJson()`.
- Update `dibuatPada` serialization to use ISO-8601 strings instead of milliseconds since epoch.

---

### API Client

#### [NEW] [api_client.dart](file:///D:/PPM_233040042_A/pertemuan_6/pertemuan6/lib/api_client.dart)

- Create a singleton `ApiClient` class to handle all HTTP communication.
- Implement `getAll()`, `getById()`, `insert()`, `update()`, and `delete()` methods.
- Include error handling for network issues (SocketException, TimeoutException) and HTTP errors (4xx/5xx).

---

### UI Components

#### [home_page.dart](file:///D:/PPM_233040042_A/pertemuan_6/pertemuan6/lib/pages/home_page.dart)

- Replace `DbHelper.instance` calls with `ApiClient.instance`.
- Update error handling in `FutureBuilder` to display `ApiException` messages.

#### [catatan_form_page.dart](file:///D:/PPM_233040042_A/pertemuan_6/pertemuan6/lib/pages/catatan_form_page.dart)

- Update `_simpan()` to use `ApiClient.instance.insert()` and `ApiClient.instance.update()`.
- Catch `ApiException` to show server-side validation or error messages.

#### [detail_catatan_page.dart](file:///D:/PPM_233040042_A/pertemuan_6/pertemuan6/lib/pages/detail_catatan_page.dart)

- Update delete logic to use `ApiClient.instance.delete()`.

---

### Cleanup

#### [DELETE] [db_helper.dart](file:///D:/PPM_233040042_A/pertemuan_6/pertemuan6/lib/db_helper.dart)

- Remove the local database helper file.

#### [main.dart](file:///D:/PPM_233040042_A/pertemuan_6/pertemuan6/lib/main.dart)

- Remove unused `DbHelper` imports and `WidgetsFlutterBinding.ensureInitialized()` if no other initialization is needed.

## Verification Plan

### Manual Verification
- **Create**: Add a new note and verify it appears in the list after refresh.
- **Read**: Verify the list of notes is fetched from the server.
- **Update**: Edit an existing note and verify changes are saved to the server.
- **Delete**: Delete a note and verify it's removed from the server.
- **Error Handling**:
    - Disable internet and verify "Tidak ada koneksi internet" message.
    - Test with an invalid API key to verify "401 Unauthorized" handling.
