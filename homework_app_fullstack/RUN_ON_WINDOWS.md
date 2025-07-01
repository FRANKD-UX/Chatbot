# How to Run the Homework App on Windows

This guide provides instructions to set up and run both the Flutter frontend and the Dart backend of the Homework App on a Windows operating system.

## 🚀 Prerequisites

Before you begin, ensure you have the following installed:

1.  **Flutter SDK**: Follow the official Flutter installation guide for Windows: [https://flutter.dev/docs/get-started/install/windows](https://flutter.dev/docs/get-started/install/windows)
    *   Make sure to add Flutter to your PATH environment variable.
    *   Run `flutter doctor` in your command prompt to verify the installation and resolve any issues.

2.  **Git**: Download and install Git for Windows: [https://git-scm.com/download/win](https://git-scm.com/download/win)

3.  **SQLite3**: The Dart backend uses SQLite. You might need to install the SQLite3 DLLs.
    *   Download the precompiled binaries for Windows from the SQLite website: [https://www.sqlite.org/download.html](https://www.sqlite.org/download.html) (look for `sqlite-dll-win64-x64-*.zip` or `sqlite-dll-win32-x86-*.zip` depending on your system).
    *   Extract the `sqlite3.dll` file and place it in a directory that is included in your system's PATH environment variable (e.g., `C:\Windows\System32` or a custom directory added to PATH).

## 📂 Project Structure

After extracting the provided zip file, you will find two main folders:

-   `homework_app/`: Contains the Flutter frontend project.
-   `homework_backend/`: Contains the Dart backend project.

## 🖥️ Backend Setup and Run

1.  **Open Command Prompt/PowerShell**:
    Navigate to the `homework_backend` directory:
    ```bash
    cd path\to\extracted\folder\homework_backend
    ```

2.  **Install Dependencies**:
    Run the following command to get the Dart dependencies:
    ```bash
    dart pub get
    ```

3.  **Run the Backend Server**:
    Start the backend server. It will run on `http://localhost:3000`.
    ```bash
    dart run bin\server.dart
    ```
    Leave this command prompt window open. The server needs to keep running for the frontend to communicate with it.

## 📱 Frontend Setup and Run

1.  **Open a New Command Prompt/PowerShell Window**:
    Navigate to the `homework_app` directory:
    ```bash
    cd path\to\extracted\folder\homework_app
    ```

2.  **Install Dependencies**:
    Run the following command to get the Flutter dependencies:
    ```bash
    flutter pub get
    ```

3.  **Run the Frontend Application**:
    You can run the Flutter app for web or for a connected mobile device/emulator.

    *   **For Web (Recommended for quick testing)**:
        This will open the app in your default web browser.
        ```bash
        flutter run -d web-server --web-port 8080
        ```
        If it doesn't open automatically, navigate to `http://localhost:8080` in your browser.

    *   **For Mobile (Android/iOS Emulator or Physical Device)**:
        Ensure you have an Android emulator running or an iOS simulator/physical device connected and configured.
        ```bash
        flutter run
        ```

## Troubleshooting

-   **`flutter` command not found**: Ensure Flutter SDK is correctly installed and added to your system's PATH.
-   **`dart` command not found**: The Dart SDK is included with Flutter. Ensure Flutter is correctly set up.
-   **Backend `SocketException: Failed to create server socket (OS Error: Address already in use)`**: This means port 3000 is already in use. Close any other applications using this port or try restarting your computer. You can also try changing the port in `homework_backend/bin/server.dart`.
-   **Backend `Failed to load dynamic library 'sqlite3.dll'`**: Ensure `sqlite3.dll` is downloaded and placed in a directory that is part of your system's PATH environment variable.
-   **Frontend connection issues**: Make sure your backend server is running (`dart run bin\server.dart`) and accessible at `http://localhost:3000`.

Enjoy using the Homework App!

