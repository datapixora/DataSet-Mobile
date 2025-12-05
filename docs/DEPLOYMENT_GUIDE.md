# DataSet Mobile App - Deployment Guide

## Overview

This guide covers deploying the complete DataSet platform:
- Backend API (Node.js + PostgreSQL)
- Admin Dashboard (Next.js)
- Mobile App (Flutter)
- Cloudflare R2 Storage

## Architecture

```
┌─────────────────┐
│  Mobile App     │
│  (Flutter)      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐      ┌──────────────┐
│  Backend API    │◄────►│  PostgreSQL  │
│  (Node.js)      │      │  Database    │
└────────┬────────┘      └──────────────┘
         │
         ▼
┌─────────────────┐
│  Cloudflare R2  │
│  Storage        │
└─────────────────┘

┌─────────────────┐
│  Admin Panel    │
│  (Next.js)      │
└────────┬────────┘
         │
         ▼
    (Same Backend API)
```

## Prerequisites

- Node.js 18+ installed
- PostgreSQL 14+ installed
- Flutter SDK 3.2+ installed
- Cloudflare account
- Git installed

## Part 1: Backend API Setup

### 1. Clone Backend Repository

```bash
git clone https://github.com/datapixora/DataSet.git
cd DataSet
npm install
```

### 2. Configure Environment Variables

Create `.env` file:

```env
# Server
PORT=5000
NODE_ENV=production

# Database
DATABASE_URL="postgresql://user:password@localhost:5432/dataset_db?schema=public"

# JWT
JWT_SECRET=your_super_secret_jwt_key_here_min_32_chars
JWT_EXPIRES_IN=7d

# Cloudflare R2
R2_ACCOUNT_ID=your_account_id
R2_ACCESS_KEY_ID=your_access_key
R2_SECRET_ACCESS_KEY=your_secret_key
R2_BUCKET_NAME=dataset-uploads
R2_ENDPOINT=https://[account-id].r2.cloudflarestorage.com

# Upload Settings
MAX_FILE_SIZE=10485760
ALLOWED_MIME_TYPES=image/jpeg,image/png,image/heic,image/webp
PRESIGNED_URL_EXPIRY=3600

# CORS
CORS_ORIGIN=*

# Admin
ADMIN_EMAIL=admin@example.com
ADMIN_PASSWORD=change_this_password
```

### 3. Setup Database

```bash
# Initialize Prisma
npx prisma generate
npx prisma db push

# Run migrations (if available)
npx prisma migrate deploy

# Seed database (optional)
npm run seed
```

### 4. Start Backend

```bash
# Development
npm run dev

# Production
npm run build
npm start
```

### 5. Verify Backend

```bash
curl http://localhost:5000/health
# Should return: { "status": "ok" }
```

## Part 2: Cloudflare R2 Setup

### 1. Create R2 Bucket

1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. Navigate to **R2**
3. Click **Create bucket**
4. Name: `dataset-uploads`
5. Click **Create**

### 2. Generate API Tokens

1. Click **Manage R2 API Tokens**
2. Click **Create API Token**
3. Name: `DataSet API`
4. Permissions: **Object Read & Write**
5. Click **Create**
6. Save the credentials:
   - Access Key ID
   - Secret Access Key
   - Endpoint URL

### 3. Configure CORS

In bucket settings, add CORS policy:

```json
[
  {
    "AllowedOrigins": ["*"],
    "AllowedMethods": ["PUT", "GET"],
    "AllowedHeaders": ["*"],
    "ExposeHeaders": ["ETag"],
    "MaxAgeSeconds": 3600
  }
]
```

### 4. Update Backend `.env`

Add the R2 credentials from step 2 to your `.env` file.

## Part 3: Deploy Backend to Render.com

### 1. Create Account

- Sign up at [render.com](https://render.com)
- Connect your GitHub account

### 2. Create Web Service

1. Click **New +** → **Web Service**
2. Connect repository: `datapixora/DataSet`
3. Configure:
   - **Name**: `visual-data-api`
   - **Environment**: `Node`
   - **Build Command**: `npm install && npx prisma generate`
   - **Start Command**: `npm start`
   - **Plan**: Free (or paid)

### 3. Add Environment Variables

Add all variables from your `.env` file in Render dashboard.

**Important:** Update `DATABASE_URL` with Render's PostgreSQL URL.

### 4. Deploy

- Click **Create Web Service**
- Wait for deployment to complete
- Note your API URL: `https://visual-data-api.onrender.com`

## Part 4: Setup PostgreSQL on Render

### 1. Create PostgreSQL Database

1. Click **New +** → **PostgreSQL**
2. Name: `dataset-db`
3. Database: `dataset_db`
4. User: `dataset_user`
5. Plan: Free (or paid)
6. Click **Create Database**

### 2. Get Connection String

Copy the **Internal Database URL** from the database page.

### 3. Update Backend Environment

In your web service environment variables, update:

```env
DATABASE_URL=postgresql://dataset_user:password@host/dataset_db
```

### 4. Run Migrations

In Render web service shell:

```bash
npx prisma migrate deploy
```

## Part 5: Mobile App Configuration

### 1. Update API URL

Edit `lib/core/config.dart`:

```dart
class AppConfig {
  static const String apiBaseUrl = "https://visual-data-api.onrender.com/v1";
}
```

### 2. Configure Android

**android/app/src/main/AndroidManifest.xml**:

```xml
<manifest>
  <uses-permission android:name="android.permission.INTERNET"/>
  <uses-permission android:name="android.permission.CAMERA"/>
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
  <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
  <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>

  <application
    android:label="DataSet"
    android:usesCleartextTraffic="false">
    ...
  </application>
</manifest>
```

### 3. Configure iOS

**ios/Runner/Info.plist**:

```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to take photos for campaigns</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to upload existing photos</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need location access to add GPS data to photos</string>
```

### 4. Build Mobile App

```bash
# Get dependencies
flutter pub get

# Build Android APK
flutter build apk --release

# Build iOS (Mac only)
flutter build ios --release

# Build for specific platforms
flutter build appbundle  # Android App Bundle for Play Store
flutter build ipa        # iOS for App Store
```

### 5. Test on Device

```bash
# Android
flutter run --release

# iOS
flutter run --release
```

## Part 6: Admin Dashboard Deployment

### 1. Configure Environment

Create `.env.local` in admin dashboard:

```env
NEXT_PUBLIC_API_URL=https://visual-data-api.onrender.com/v1
```

### 2. Deploy to Vercel

```bash
# Install Vercel CLI
npm i -g vercel

# Login
vercel login

# Deploy
cd visual-data-admin
vercel --prod
```

Or connect GitHub repo to Vercel dashboard for auto-deployment.

## Part 7: Testing Complete System

### 1. Test Backend API

```bash
# Health check
curl https://visual-data-api.onrender.com/health

# Register user
curl -X POST https://visual-data-api.onrender.com/v1/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test123!",
    "fullName": "Test User"
  }'
```

### 2. Test Mobile App

1. **Install on device**
2. **Sign up** with email/password
3. **Browse campaigns**
4. **Upload a photo**:
   - Select from gallery
   - Take with camera
   - Check upload progress
   - Verify success message
5. **Check profile**:
   - View earnings
   - Check upload history
   - View level and XP
6. **Test gamification**:
   - View achievements
   - Check leaderboard
7. **Test settings**:
   - Edit profile
   - Toggle preferences

### 3. Test Admin Dashboard

1. Login with admin credentials
2. View platform statistics
3. Review photo submissions
4. Approve/reject uploads
5. Manage campaigns

## Part 8: Production Checklist

### Security
- [ ] Change all default passwords
- [ ] Use strong JWT secret (min 32 characters)
- [ ] Enable HTTPS only
- [ ] Configure CORS properly
- [ ] Set up rate limiting
- [ ] Enable API request logging
- [ ] Implement proper error handling

### Database
- [ ] Set up automated backups
- [ ] Configure connection pooling
- [ ] Add database indexes
- [ ] Enable query logging
- [ ] Set up monitoring

### Storage
- [ ] Configure R2 lifecycle policies
- [ ] Set up CDN (if using custom domain)
- [ ] Enable versioning
- [ ] Configure backup retention

### Mobile App
- [ ] Update app version numbers
- [ ] Add proper app icons
- [ ] Configure splash screens
- [ ] Set up crash reporting
- [ ] Add analytics (optional)
- [ ] Test on multiple devices
- [ ] Optimize images and assets

### Monitoring
- [ ] Set up uptime monitoring
- [ ] Configure error tracking (Sentry)
- [ ] Enable performance monitoring
- [ ] Set up log aggregation
- [ ] Create alerts for errors

## Part 9: App Store Submission

### Google Play Store

1. **Prepare Assets**:
   - App icon (512x512 PNG)
   - Feature graphic (1024x500)
   - Screenshots (multiple sizes)
   - Privacy policy URL

2. **Build Release**:
   ```bash
   flutter build appbundle --release
   ```

3. **Submit**:
   - Create developer account ($25 one-time)
   - Upload AAB file
   - Fill app details
   - Submit for review

### Apple App Store

1. **Prepare Assets**:
   - App icon (1024x1024 PNG)
   - Screenshots (various sizes)
   - Privacy policy URL

2. **Build Release**:
   ```bash
   flutter build ipa --release
   ```

3. **Submit**:
   - Create developer account ($99/year)
   - Upload IPA via Xcode or Transporter
   - Fill app details
   - Submit for review

## Part 10: Maintenance

### Regular Tasks

**Daily**:
- Monitor error logs
- Check upload success rates
- Review user feedback

**Weekly**:
- Database backup verification
- Performance metrics review
- Security updates check

**Monthly**:
- Cost analysis
- User engagement metrics
- Feature usage analytics

### Updates

**Backend Updates**:
```bash
git pull origin main
npm install
npx prisma migrate deploy
npm run build
pm2 restart all  # or Render auto-deploys
```

**Mobile App Updates**:
```bash
# Update version in pubspec.yaml
version: 1.0.1+2  # version+build number

# Build and deploy
flutter build appbundle --release
# Submit to stores
```

## Support & Resources

- **Documentation**: See `docs/` folder
- **API Docs**: `https://your-api.com/docs`
- **GitHub Issues**: Report bugs and request features
- **Cloudflare R2**: https://developers.cloudflare.com/r2/

## Troubleshooting

### Mobile App Not Connecting

1. Check API URL in `config.dart`
2. Verify backend is running
3. Check network permissions
4. Clear app cache and reinstall

### Upload Failing

1. Check R2 credentials
2. Verify CORS configuration
3. Check file size limits
4. Review presigned URL expiry

### Database Connection Issues

1. Verify connection string
2. Check database is running
3. Review connection pool settings
4. Check firewall rules

## Cost Estimation

**Monthly Costs (Low Traffic)**:
- Render Web Service: Free tier or $7/month
- Render PostgreSQL: Free tier or $7/month
- Cloudflare R2: ~$0.50/month (10K uploads)
- Vercel (Admin): Free tier
- **Total: $0-15/month**

**Monthly Costs (Medium Traffic)**:
- Render Web Service: $25/month
- Render PostgreSQL: $15/month
- Cloudflare R2: ~$5/month (100K uploads)
- Vercel: Free tier
- **Total: ~$45/month**

## Conclusion

Your DataSet platform is now deployed and ready for production! 🎉

The complete stack includes:
- ✅ Mobile app for contributors
- ✅ Backend API with authentication
- ✅ PostgreSQL database
- ✅ Cloudflare R2 storage
- ✅ Admin dashboard
- ✅ Gamification system
- ✅ Payment tracking

All systems are integrated and ready to scale!
