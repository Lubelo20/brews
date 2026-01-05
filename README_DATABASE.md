# Brews of Opportunity - Database Setup Guide

## Overview

This guide explains how to set up and configure the MySQL database for the Brews of Opportunity website. The database handles all form submissions, content management, and administrative functions.

## Files Created

### Database Schema
- `sql/brews_database_complete.sql` - Complete database schema with all tables
- `sql/create_tables.sql` - Original basic schema (can be replaced)

### API Endpoints
- `api/config.php` - Database configuration and helper functions
- `api/submissions.php` - API endpoints for form submissions

### Frontend Integration
- `js/form-handler.js` - JavaScript form handling for all website forms

## Database Structure

### Core Tables
- `users` - Admin and user management
- `training_signups` - Training course registrations
- `sponsor_enquiries` - Sponsorship interest forms
- `contact_submissions` - Contact form messages
- `newsletter_subscriptions` - Newsletter signups

### Content Management
- `programs` - Coffee programs (Mobile Carts, Spaza Shops, etc.)
- `training_courses` - Training courses and workshops
- `products` - Uniform combos and merchandise
- `sponsorship_tiers` - Sponsorship levels and benefits

### Additional Features
- `gallery_images` - Website gallery management
- `site_settings` - Dynamic website settings
- `activity_log` - Admin activity tracking

## Installation Steps

### 1. Database Setup

```bash
# Import the complete database schema
mysql -u root -p < sql/brews_database_complete.sql
```

### 2. Configure Database Connection

Edit `api/config.php` and update the database credentials:

```php
define('DB_HOST', 'localhost');
define('DB_NAME', 'brews_opportunity');
define('DB_USER', 'your_db_user');
define('DB_PASS', 'your_db_password');
```

### 3. Set API Token (Optional)

For secure API access, update the API token in `api/config.php`:

```php
define('API_TOKEN', 'your-secure-api-token-here');
```

### 4. Web Server Configuration

Ensure your web server supports PHP and has the following extensions:
- PDO MySQL
- JSON
- mbstring

### 5. File Permissions

Set appropriate permissions for the API directory:

```bash
chmod 755 api/
chmod 644 api/*.php
```

## Form Integration

The database now automatically handles submissions from:

1. **Training Form** (`training.html`)
   - Captures course registrations
   - Stores in `training_signups` table

2. **Contact Form** (`contact.html`)
   - Captures visitor messages
   - Stores in `contact_submissions` table

3. **Newsletter Forms** (all pages)
   - Captures email subscriptions
   - Stores in `newsletter_subscriptions` table

4. **Sponsor Forms** (when implemented)
   - Captures sponsorship enquiries
   - Stores in `sponsor_enquiries` table

## Admin Panel

The admin panel at `admin.html` now connects to the database:

1. **Login Credentials**
   - Username: `Admin`
   - Password: `Ndumash*15` (change this in production)

2. **Features**
   - View all form submissions
   - Filter by submission type
   - Export data (can be enhanced)

3. **API Integration**
   - Uses the new API endpoints
   - Supports token authentication
   - Real-time data loading

## API Endpoints

### Form Submissions

| Endpoint | Method | Description |
|----------|--------|-------------|
| `api/submissions.php?action=training` | POST | Submit training registration |
| `api/submissions.php?action=sponsor` | POST | Submit sponsor enquiry |
| `api/submissions.php?action=contact` | POST | Submit contact message |
| `api/submissions.php?action=newsletter` | POST | Subscribe to newsletter |

### Data Retrieval (Admin)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `api/submissions.php?action=list` | GET | Get all submissions |
| `api/submissions.php?action=list&type=training` | GET | Get training submissions |
| `api/submissions.php?action=list&type=sponsor` | GET | Get sponsor submissions |
| `api/submissions.php?action=list&type=contact` | GET | Get contact submissions |

## Security Considerations

1. **Database Security**
   - Change default admin password
   - Use dedicated database user with limited privileges
   - Enable SSL for database connections in production

2. **API Security**
   - Set a secure API token
   - Implement rate limiting
   - Validate all input data

3. **Frontend Security**
   - All forms include CSRF protection
   - Input validation on both client and server side
   - XSS protection with proper escaping

## Sample Data

The database script includes commented sample data. To populate with test data:

1. Open `sql/brews_database_complete.sql`
2. Uncomment the sample data section
3. Run the script again or execute the INSERT statements manually

## Email Notifications

The API includes placeholder email notification functions. To enable:

1. Configure PHP mail settings
2. Uncomment the `mail()` calls in `api/submissions.php`
3. Update email addresses in the notification functions

## Backup and Maintenance

### Regular Backups
```bash
# Create backup
mysqldump -u root -p brews_opportunity > backup_$(date +%Y%m%d).sql

# Restore backup
mysql -u root -p brews_opportunity < backup_20231201.sql
```

### Maintenance Tasks
- Optimize tables monthly: `OPTIMIZE TABLE training_signups, sponsor_enquiries, contact_submissions;`
- Monitor disk space and performance
- Review and archive old submissions if needed

## Troubleshooting

### Common Issues

1. **Database Connection Failed**
   - Check database credentials in `api/config.php`
   - Ensure MySQL server is running
   - Verify database exists

2. **Form Submissions Not Working**
   - Check browser console for JavaScript errors
   - Verify API endpoint is accessible
   - Check PHP error logs

3. **Admin Panel Not Loading Data**
   - Verify API token if using authentication
   - Check network requests in browser dev tools
   - Ensure database has data to display

### Debug Mode

To enable debug logging, add to `api/config.php`:
```php
define('DEBUG_MODE', true);
```

## Next Steps

1. **Production Deployment**
   - Move to production database
   - Set up proper domain and SSL
   - Configure production email settings

2. **Enhanced Features**
   - Add email campaign management
   - Implement user accounts for trainees
   - Add reporting and analytics

3. **Performance Optimization**
   - Add database indexes for large datasets
   - Implement caching for frequently accessed data
   - Set up database replication for high availability

## Support

For issues or questions:
1. Check this documentation first
2. Review error logs in PHP and MySQL
3. Test API endpoints directly with tools like Postman
4. Verify database structure matches the schema

---

**Note**: This database setup provides a solid foundation for the Brews of Opportunity website. All major features are now integrated with proper data storage and management capabilities.
