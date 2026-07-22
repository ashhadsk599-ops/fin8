# Cura Meal - Dual Client Platform 🏥🍽️

Welcome to **Cura Meal**! This project contains two completely independent, production-ready frontend clients built to provide a seamless bedside hospital nourishment experience:

1. **Web App**: A modern, responsive React + Vite + Tailwind CSS Single-Page Application (SPA).
2. **Mobile App**: A cross-platform Flutter + Dart application utilizing the `Provider` state management architecture.

Both applications share the exact same asset files and branding, but are structured to run and build completely individually.

---

## 📂 Project Organization & Separation

To ensure clean decoupling, both applications reside in dedicated directories and use separate runtime/package configurations:

| Client App | Root Files & Code Directories | Configuration File | Language / Framework |
| :--- | :--- | :--- | :--- |
| 💻 **React Web Client** | `/src`, `/public`, `/index.html`, `/vite.config.ts` | `package.json` | TypeScript, React, Tailwind CSS |
| 📱 **Flutter Mobile Client** | `/lib`, `/android`, `/ios`, `/assets` | `pubspec.yaml` | Dart, Flutter |

---

## 💻 1. Web Application (React + Vite)

The web client provides a fully-featured patient bedside portal, hospital directory navigation, custom meal customization, and active delivery tracking inside a modern, modular design.

### How to Run Locally:
Make sure you have [Node.js](https://nodejs.org/) installed on your machine.

1. **Install web dependencies**:
   ```bash
   npm install
   ```

2. **Run the development server**:
   ```bash
   npm run dev
   ```
   *The app will boot up on `http://localhost:3000` (or the mapped host port).*

3. **Build the production bundle**:
   ```bash
   npm run build
   ```
   *The static build outputs will be compiled into the `/dist` directory.*

---

## 📱 2. Mobile Application (Flutter)

The Flutter mobile application features identical high-fidelity features (Admission Check-in, Ward/Room/Bed tracking, Hospital selection, Dietary filters, Thermal double-seal options, and Live Bedside Delivery tracker) wrapped in smooth Material widgets.

### How to Run Locally:
Make sure you have the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed on your system.

1. **Retrieve Dart dependencies**:
   ```bash
   flutter pub get
   ```

2. **Connect your device / start an emulator**:
   Ensure USB debugging is active on your physical Android/iOS device, or start a virtual emulator.

3. **Run the app**:
   ```bash
   flutter run
   ```

### 🤖 Download the Compiled Android App (.APK) via GitHub Actions
This repository is configured with an automated **GitHub Actions CI Workflow** that compiles the `.apk` on every push!

1. Open the **Settings Menu** (Gear Icon) in AI Studio and choose **Push to GitHub** to link your repository.
2. Push your code. Once pushed, navigate to your repository on GitHub.
3. Click the **Actions** tab at the top.
4. Select the latest **Build Android APK** workflow run.
5. Scroll down to **Artifacts** and click **healthy-plate-app-release** to download the ready-to-use `.apk` directly to your phone!

