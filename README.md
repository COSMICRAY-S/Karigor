# Karigor Khoj (কারিগর খোঁজ)

**Karigor Khoj** is a full-stack platform designed to connect customers with skilled local service providers (Karigors) quickly and efficiently based on GPS location and service categories.

## Key Features

- **Authentication & Roles**: Customer (Seeker) and Service Provider (Karigor) registration and login with JWT and password encryption.
- **Location-Based Search**: Real-time GPS distance calculation (Haversine formula in PostgreSQL) to find nearby service providers within a given radius.
- **Service Request Management**: Send, accept, reject, and complete service requests with real-time status tracking.
- **Reviews & Ratings**: Customers can review and rate completed jobs; automatic calculation of provider ratings.
- **Profile Management**: Providers can update their service category, bio, and toggle online/offline availability.

## Technologies Used

### Frontend
- **Flutter** & **Dart**
- State Management: `Provider`
- Networking: `http`
- Location Services: `geolocator`, `geocoding`
- Local Storage: `shared_preferences`

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
