# Onukul Database Setup Guide

## 🚀 Quick Setup (Recommended)

### Step 1: Start MySQL Server
```bash
# For XAMPP (Windows/Mac):
# Start XAMPP Control Panel and click "Start" for MySQL

# For MAMP (Mac):
# Start MAMP and click "Start Servers"

# For Linux/Ubuntu:
sudo service mysql start

# For macOS with Homebrew:
brew services start mysql
```

### Step 2: Run Setup Script
1. Open your browser
2. Navigate to: `http://localhost/setup_db.php`
3. The script will automatically:
   - Create the database
   - Import all tables and data
   - Verify the connection

### Step 3: Test Connection
1. Open: `http://localhost/test_connection.html`
2. Click "সংযোগ পরীক্ষা করুন" (Test Connection)
3. Verify all tables are found

### Step 4: Use the Application
1. Open: `http://localhost/index.html`
2. The app will automatically connect to the database
3. Login with test accounts (see below)

## 🔧 Manual Setup (Alternative)

### Option 1: Using phpMyAdmin
1. Start XAMPP/MAMP
2. Open: `http://localhost/phpmyadmin`
3. Create database: `onukul`
4. Import: `onukul.sql`

### Option 2: Using Command Line
```bash
# Create database
mysql -u root -p -e "CREATE DATABASE onukul CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# Import schema
mysql -u root -p onukul < onukul.sql
```

## 🔍 Troubleshooting

### If Setup Fails:
1. Run: `http://localhost/check_config.php`
2. This will test different password configurations
3. Update your PHP files with the working credentials

### Common Issues:

#### ❌ "Access denied for user 'root'@'localhost'"
- MySQL root password is different
- Run `check_config.php` to find correct password
- Update all PHP files with correct credentials

#### ❌ "Can't connect to MySQL server"
- MySQL service not running
- Start MySQL in XAMPP/MAMP control panel
- Check if port 3306 is blocked by firewall

#### ❌ "Database doesn't exist"
- Run `setup_db.php` to create database automatically
- Or create manually in phpMyAdmin

## 👥 Test Accounts

| Role | NID | Password | Access |
|------|-----|----------|--------|
| Admin | 12345678910 | admin | Full admin panel |
| Volunteer | 1234567896 | Kam@l321 | Volunteer dashboard |
| Needy | 1234567891 | SaraPwd9 | Aid request form |
| Donor | 1234567890 | AliPass12 | Donation form |

## 📁 File Structure

```
/onukul/
├── index.html          # Main application
├── api.php            # REST API endpoints
├── db.php             # Database connection
├── onukul.sql         # Database schema
├── setup_db.php       # Auto setup script
├── check_config.php   # Configuration tester
├── test_connection.html # Connection test UI
├── db_test.php        # Backend connection test
├── import_sql.php     # Manual import script
└── app.js             # Frontend API functions
```

## 🔗 API Endpoints

- `GET /api.php?action=users` - Get all users
- `POST /api.php?action=users` - Register new user
- `GET /api.php?action=inventory` - Get inventory items
- `GET /api.php?action=packages` - Get aid packages
- `GET /api.php?action=aidRequests` - Get aid requests
- `GET /api.php?action=donations` - Get donations

## 🎯 Features

✅ User registration and authentication
✅ Role-based access control (Admin, Volunteer, Needy, Donor)
✅ Aid request management
✅ Inventory tracking
✅ Package management
✅ Donation tracking
✅ Volunteer district mapping
✅ Admin dashboard with analytics
✅ Responsive design
✅ API integration with localStorage fallback

## 📞 Support

If you encounter issues:
1. Check browser console for JavaScript errors
2. Verify database connection with `test_connection.html`
3. Test API endpoints directly in browser
4. Check PHP error logs if using custom server

---

**Happy coding with Onukul! 🎉**
