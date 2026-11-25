# Karigor Khoj (কারিগর খোঁজ)

**Karigor Khoj** is a full-stack on-demand service marketplace designed to connect customers with skilled local service providers (Karigors) quickly and efficiently based on GPS location, intelligent AI assistance, and service categories.

---

## 🎨 New Design & Features

The app features a culturally inspired terracotta and brass design system along with an integrated AI assistant:

### 1. **Terracotta & Brass Design Theme**
- **Palette**: Clay background (`#FBF3E7`), Terracotta accents (`#C1502E`), Brass gradients (`#C89B3C`), Slate green containers (`#3E5C55`), and clean panel styling.
- **Typography**: Bengali aesthetic with support for *Baloo Da 2* and *Hind Siliguri*.
- **Role Selection Screen**: Visual dual-card selector with seamless one-tap authentication for both Seekers and Karigors.

### 2. **Karigor AI Assistant (কারিগর খোঁজ AI)**
- **Multilingual NLP**: Understands natural conversational queries in **Bangla, English, and Banglish** (e.g., *"gas line e problem hocche"*, *"চুলা থেকে গ্যাস বের হচ্ছে"*, *"electrician দরকার"*).
- **Smart Intent & Trade Classification**: Automatically identifies service categories including Gas Line, Electrical, Plumbing, Carpentry, AC/Cooling, and Painting.
- **Budget Extraction & Safety Tips**: Detects offered budgets from conversational text and gives practical safety advice (e.g. gas leak safety precautions, circuit breaker safety) before a Karigor arrives.
- **Embedded Provider Matching**: Immediately finds and presents available online providers in the chat with a direct "অনুরোধ" (Request) button.

### 3. **1-on-1 Direct Messaging (Seeker ↔ Karigor Chat)**
- Direct chat window connecting customers and service providers.
- Quick suggestion chips (*"আপনি কখন আসতে পারবেন?"*, *"খরচ কেমন হবে?"*, *"ঠিকানা পাঠাচ্ছি"*).
- Real-time status indicators (🟢 অনলাইন / ⚪ অফলাইন).

### 4. **Service Request Bottom-Sheet Modal**
- Clean sliding bottom sheet for instant job request submission.
- Fields for work description, address location, and proposed budget in BDT (৳).
- Live validation and automatic syncing with the backend and local state.

### 5. **All Karigors Directory (Filter & Sort)**
- Category filter chips: সব ধরন, 🔥 গ্যাস লাইন, 🔌 ইলেকট্রিশিয়ান, 🚰 প্লাম্বার, 🪚 কাঠমিস্ত্রি, ❄️ এসি, 🎨 রং মিস্ত্রি.
- Dual sorting options: **🟢 সক্রিয় অবস্থা (Online status first)** and **📍 দূরত্ব (Distance)**.
- Direct action buttons on every card: **📞 কল**, **💬 চ্যাট**, and **অনুরোধ**.

### 6. **Karigor Dashboard (Job Feed & Online Switch)**
- Live online/offline toggle switch that updates provider availability in real-time.
- Incoming job requests feed with customer details, distance, description, budget, and **"সাড়া দিন" / "এড়িয়ে যান"** actions.
- Past completed jobs history and ratings breakdown.

### 7. **Profile & GPS Location Detection**
- Automatic device GPS detection via `Geolocator` with estimated fallback.
- **"আমার চ্যাটসমূহ"**: Direct access to ongoing conversations with Karigors.
- Account settings and secure logout.

---

## Key Backend & Full-Stack Capabilities

- **Authentication & Roles**: Customer (Seeker) and Service Provider (Karigor) registration and login with JWT and Bcrypt password hashing.
- **Location-Based Search**: Real-time GPS distance calculation (Haversine formula in PostgreSQL) to find nearby service providers within a given radius.
- **Service Request Management**: Send, accept, reject, and complete service requests with real-time status tracking.
- **Reviews & Ratings**: Customers can review and rate completed jobs; automatic calculation of provider ratings.
- **Profile Management**: Providers can update their service category, bio, and toggle online/offline availability.

---

## Technologies Used

### Frontend
- **Flutter** & **Dart**
- State Management: `Provider` & `ChangeNotifier`
- Networking: `http` (REST API client)
- Location Services: `geolocator`, `geocoding`
- Local Storage: `shared_preferences`
- Styling: Custom Terracotta/Brass AppTheme with Material 3

### Backend
- **Node.js** & **Express**
- **PostgreSQL** (`pg` connection pool)
- **JWT** (`jsonwebtoken`) for authentication
- **Bcrypt.js** for password hashing
- **CORS** & **dotenv**

---

## Installation and Setup

### 1. Database Setup (PostgreSQL)

Create a PostgreSQL database named `karigor_khoj`:

```sql
CREATE DATABASE karigor_khoj;
```

Run the schema script located at `karigor_backend/schema.sql` inside your PostgreSQL database to create all required tables and indexes:

```bash
psql -U postgres -d karigor_khoj -f karigor_backend/schema.sql
```

### 2. Backend Setup

Navigate to the `karigor_backend` directory:

```bash
cd karigor_backend
```

Configure your `.env` file (copy from `.env.example` if needed):

```env
DATABASE_URL=postgresql://postgres:YOUR_PASSWORD@localhost:5432/karigor_khoj
JWT_SECRET=karigor_khoj_super_secret_2024
PORT=3000
```

Install dependencies and start the backend server:

```bash
npm install
npm run dev # or npm start
```

Backend will be accessible at: `http://localhost:3000`

### 3. Frontend Setup

Open another terminal and navigate to `karigor_khoj`:

```bash
cd karigor_khoj
flutter pub get
flutter run
```

*Note:* If running on Android Emulator, `ApiService.baseUrl` automatically routes to `http://10.0.2.2:3000/api`. On Web/Desktop, it uses `http://localhost:3000/api`.
