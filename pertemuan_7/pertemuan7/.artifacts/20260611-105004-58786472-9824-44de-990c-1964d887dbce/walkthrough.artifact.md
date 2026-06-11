# Walkthrough - Pertemuan 5: REST API & Network Error Handling

I have completed the transition from local SQLite to a remote REST API. A major focus was ensuring robust error handling for network issues.

## Key Changes

### 1. REST API Integration
- **`ApiClient`**: A new singleton class handles all communication with the server (`besab-production.up.railway.app`).
- **`Catatan` Model**: Updated to support JSON serialization and ISO-8601 date strings.
- **Removed SQLite**: `DbHelper` and its dependencies (`sqflite`, `path`) have been removed.

### 2. Robust Error Handling (Langkah 8.2)
I have implemented specific handling for the scenarios you mentioned:

- **No Internet Connection**: When a `SocketException` occurs (e.g., Wi-Fi is off), the app now catches it and throws an `ApiException` with the message "Tidak ada koneksi internet."
- **Timeout**: If the server takes too long to respond (>10s), it shows "Server tidak merespons (timeout)."
- **HTTP Errors**:
    - **401 Unauthorized**: If the API key is wrong, it shows the message from the server.
    - **422 Unprocessable Entity**: Handles validation errors from the server.

### 3. UI for Error Recovery (Langkah 5)
The `HomePage` now has a dedicated error state in its `FutureBuilder`:
- Displays a **"wifi_off" icon**.
- Shows the specific **error message** (e.g., "Tidak ada koneksi internet.").
- Provides a **"Coba lagi" (Try again)** button that triggers a fresh data fetch.

## Verification of Scenario 8.2

To verify the "No internet" reaction:
1. **Turn off your internet/Wi-Fi.**
2. **Press the Refresh icon** in the AppBar or pull down the list.
3. You should now see:
    - An icon of a crossed-out Wi-Fi.
    - The text: **"Tidak ada koneksi internet."**
    - A blue button: **"Coba lagi"**.
4. **Turn on your internet** and click **"Coba lagi"**; the data will load correctly.

---

## How to Test Other Scenarios
- **Invalid API Key**: Go to `lib/api_client.dart`, change `_apiKey` to something random, and refresh the Home page.
- **Invalid URL**: Change `_baseUrl` to a non-existent domain and refresh.
