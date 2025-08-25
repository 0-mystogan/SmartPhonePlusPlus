# 📱 SmartPhone++ — Next-Gen Mobile Device Ecosystem

> **A comprehensive smartphone management platform combining e-commerce, repair services, and intelligent recommendations**

SmartPhone++ is a full-stack solution that bridges the gap between smartphone retail, professional repair services, and customer experience through advanced technology integration.

## 🏗️ **System Architecture**

```
SmartPhone++/
├── 🌐 SmartPhone.WebAPI/         → RESTful API Gateway (Port 5130)
├── ⚙️  SmartPhone.Services/       → Business Logic & Data Access Layer
├── 📊 SmartPhone.Model/          → Data Transfer Objects & Request Models
├── 📨 SmartPhone.Subscriber/     → Background Notification Service (Port 7111)
└── 🖥️  UI/                       → Multi-Platform Client Applications
    ├── 📱 smartphone_mobile_client/    → Customer Mobile App (Flutter)
    └── 🖥️  smartphone_desktop_admin/   → Admin Dashboard (Flutter Desktop)
```

---

## 👥 **Access Control System**

### **Role-Based Authentication**

| **Role** | **Username** | **Password** | **Capabilities** |
|----------|--------------|--------------|------------------|
| 🛡️ **Administrator** | `admin` | `test` | Full system control, user management, analytics |
| 🔧 **Technician** | `technician` | `test` | Service management, parts inventory, repair tracking |
| 👤 **Customer** | `user` | `test` | Product browsing, purchases, service requests |

---

## 🛠️ **Technology Stack**

### **Backend Infrastructure**
- **.NET 8 Web API**: High-performance REST API with Swagger documentation
- **Entity Framework Core**: Advanced ORM with migrations and seeding
- **SQL Server**: Robust relational database (Port 1401)
- **RabbitMQ**: Message queue system (Ports 5672/15672)
- **Docker Compose**: Containerized deployment orchestration

### **Frontend Applications**
- **Flutter**: Cross-platform mobile and desktop applications
- **Dart**: Modern programming language for UI development
- **Provider Pattern**: State management for reactive user interfaces
- **Stripe Integration**: Secure payment processing

### **DevOps & Infrastructure**
- **Docker**: Containerization for consistent deployment
- **Multi-stage Builds**: Optimized container images
- **Environment Configuration**: Flexible deployment settings
- **Health Checks**: Automated service monitoring

---

## 📧 **Testing & Development**

### **RabbitMQ Email Testing**
For testing notification systems and service communications:

- **Test Email**: `smartphoneplusplus.receiver@gmail.com`
- **Purpose**: Receives automated notifications for system events
- **Triggers**: When Service is completed

### **Payment Testing**
- **Stripe Test Cards**: 4242 4242 4242 4242
- **Order Processing**: Complete e-commerce workflow testing

---

## 🚀 **Quick Start Guide**

### **1. Infrastructure Setup**
```bash
# Launch all services with Docker
docker-compose up --build

# Services will be available at:
# - API: http://localhost:5130
# - RabbitMQ Management: http://localhost:15672
# - SQL Server: localhost:1401
```

### **2. Database Initialization**
```bash
# Navigate to API project
cd SmartPhone++/SmartPhone.WebAPI

# Apply database migrations
dotnet ef database update --project ../SmartPhone.Services
```

### **3. Mobile Client**
```bash
# Navigate to mobile app
cd UI/smartphone_mobile_client

# Install dependencies
flutter pub get

# Run on web browser
flutter run -d chrome

# Run on mobile device
flutter run -d <device-id>
```

### **4. Desktop Admin**
```bash
# Navigate to admin dashboard
cd UI/smartphone_desktop_admin

# Install dependencies
flutter pub get

# Run desktop application
flutter run -d windows  # or -d macos, -d linux
```

---

## 📊 **API Documentation**

Once the system is running, comprehensive API documentation is available at:
- **Swagger UI**: `http://localhost:5130/swagger`
- **OpenAPI Specification**: Auto-generated with detailed endpoint descriptions
- **Authentication**: Bearer token-based security with role validation

---

## 🔄 **Development Workflow**

### **Database Changes**
```bash
# Create new migration
dotnet ef migrations add MigrationName --project ./SmartPhone.Services --startup-project ./SmartPhone.WebAPI

# Apply changes
update-database
```

### **Flutter Code Generation**
```bash
# Generate model classes after API changes
dart run build_runner build
