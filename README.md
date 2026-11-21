
# Karigor Khoj

**Karigor Khoj** is a platform designed to connect customers with skilled local service providers (Karigors) easily and efficiently.

## About the Project

Karigor Khoj aims to make it easier for people to find and hire skilled workers for different types of services. It helps customers discover service providers and connect with them through a digital platform.

## Key Features

- User Registration and Login
- Customer and Service Provider Profiles
- Search and Find Skilled Workers
- Service Provider Information
- Backend API Integration
- [Add other implemented features here]

## Technologies Used

### Frontend
- Flutter
- Dart

### Backend
- Python
- Django
- Django REST Framework

### Database
- [Add your database name]

## Project Structure

```text
Karigor-Khoj/
├── karigor_khoj/       # Flutter Frontend
├── karigor_backend/    # Django Backend
├── README.md
└── .gitignore
```

## Installation and Setup

### 1. Clone the Repository

```bash
git clone YOUR_REPOSITORY_URL
cd Karigor-Khoj
```

### 2. Setup Backend

```bash
cd karigor_backend
python -m venv venv
```

Activate virtual environment:

Windows:
```bash
venv\Scripts\activate
```

Install dependencies:

```bash
pip install -r requirements.txt
```

Run migrations:

```bash
python manage.py migrate
```

Start Django server:

```bash
python manage.py runserver
```

### 3. Setup Frontend

Open another terminal:

```bash
cd karigor_khoj
flutter pub get
flutter run
```

## Future Improvements

- Online Booking System
- Ratings and Reviews
- Real-time Notifications
- Payment Integration
- Improved Search and Filtering

## Developer

Developed as an academic project.

## License

This project is currently developed for educational purposes.
