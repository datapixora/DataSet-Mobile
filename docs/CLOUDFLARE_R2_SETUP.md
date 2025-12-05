# Cloudflare R2 Storage Setup Guide

## Overview

The DataSet Mobile app uses **Cloudflare R2** for scalable, S3-compatible object storage. This guide explains how R2 integrates with the app and how to configure it.

## Why Cloudflare R2?

- **Cost-Effective**: Zero egress fees (unlike AWS S3)
- **S3-Compatible**: Works with existing S3 tools and SDKs
- **Fast**: Cloudflare's global network
- **Secure**: Built-in access controls and presigned URLs
- **Scalable**: Unlimited storage

## Mobile App Integration

The mobile app already supports Cloudflare R2 through a three-step upload process:

### Upload Flow

```
1. Mobile App → Backend: POST /uploads/initiate
   Request: { campaignId, fileName, mimeType }
   Response: { uploadUrl, fileKey }

2. Mobile App → R2: PUT [uploadUrl] with file binary
   Direct upload to Cloudflare R2 using presigned URL

3. Mobile App → Backend: POST /uploads/complete
   Request: { campaignId, fileKey, metadata }
   Response: { upload object with status }
```

### Key Features in Mobile App

- ✅ **Direct Upload**: Files upload directly to R2 (not through backend)
- ✅ **Progress Tracking**: Real-time upload progress
- ✅ **Presigned URLs**: Secure, time-limited upload URLs
- ✅ **Metadata Support**: GPS coordinates, timestamps
- ✅ **Multi-file Support**: Batch uploads
- ✅ **Error Handling**: Retry logic and user feedback

## Backend Configuration

### 1. Create Cloudflare R2 Bucket

```bash
# Log in to Cloudflare Dashboard
https://dash.cloudflare.com/

# Navigate to R2
1. Click "R2" in the sidebar
2. Click "Create bucket"
3. Choose a bucket name (e.g., "dataset-uploads")
4. Select location (Automatic recommended)
5. Click "Create bucket"
```

### 2. Generate R2 API Tokens

```bash
# In Cloudflare Dashboard → R2
1. Click "Manage R2 API Tokens"
2. Click "Create API Token"
3. Token name: "DataSet API"
4. Permissions: Object Read & Write
5. Specify bucket or leave for all buckets
6. Click "Create API Token"
7. Save these credentials securely:
   - Access Key ID
   - Secret Access Key
   - Endpoint URL (e.g., https://[account-id].r2.cloudflarestorage.com)
```

### 3. Backend Environment Variables

Add to your backend `.env` file:

```env
# Cloudflare R2 Configuration
R2_ACCOUNT_ID=your_account_id_here
R2_ACCESS_KEY_ID=your_access_key_here
R2_SECRET_ACCESS_KEY=your_secret_access_key_here
R2_BUCKET_NAME=dataset-uploads
R2_PUBLIC_URL=https://your-custom-domain.com  # Optional: for public access
R2_ENDPOINT=https://[account-id].r2.cloudflarestorage.com

# Upload Configuration
MAX_FILE_SIZE=10485760  # 10MB in bytes
ALLOWED_MIME_TYPES=image/jpeg,image/png,image/heic,image/webp
PRESIGNED_URL_EXPIRY=3600  # 1 hour in seconds
```

### 4. Backend Implementation (Node.js Example)

#### Install AWS SDK for S3 (R2 Compatible)

```bash
npm install @aws-sdk/client-s3 @aws-sdk/s3-request-presigner
```

#### Configure S3 Client for R2

```javascript
// config/r2.js
const { S3Client } = require('@aws-sdk/client-s3');

const r2Client = new S3Client({
  region: 'auto',
  endpoint: process.env.R2_ENDPOINT,
  credentials: {
    accessKeyId: process.env.R2_ACCESS_KEY_ID,
    secretAccessKey: process.env.R2_SECRET_ACCESS_KEY,
  },
});

module.exports = r2Client;
```

#### Initiate Upload Endpoint

```javascript
// controllers/uploadController.js
const { PutObjectCommand } = require('@aws-sdk/client-s3');
const { getSignedUrl } = require('@aws-sdk/s3-request-presigner');
const r2Client = require('../config/r2');
const crypto = require('crypto');

async function initiateUpload(req, res) {
  const { campaignId, fileName, mimeType } = req.body;
  const userId = req.user.id; // From auth middleware

  // Generate unique file key
  const fileKey = `uploads/${userId}/${campaignId}/${Date.now()}-${crypto.randomUUID()}-${fileName}`;

  // Create presigned URL for upload
  const command = new PutObjectCommand({
    Bucket: process.env.R2_BUCKET_NAME,
    Key: fileKey,
    ContentType: mimeType,
  });

  try {
    const uploadUrl = await getSignedUrl(r2Client, command, {
      expiresIn: parseInt(process.env.PRESIGNED_URL_EXPIRY),
    });

    res.status(200).json({
      success: true,
      data: {
        uploadUrl,
        fileKey,
      },
    });
  } catch (error) {
    console.error('R2 presigned URL error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to generate upload URL',
    });
  }
}
```

#### Complete Upload Endpoint

```javascript
async function completeUpload(req, res) {
  const { campaignId, fileKey, metadata } = req.body;
  const userId = req.user.id;

  // Verify file exists in R2
  const { HeadObjectCommand } = require('@aws-sdk/client-s3');
  try {
    await r2Client.send(new HeadObjectCommand({
      Bucket: process.env.R2_BUCKET_NAME,
      Key: fileKey,
    }));
  } catch (error) {
    return res.status(404).json({
      success: false,
      message: 'File not found in storage',
    });
  }

  // Save upload record to database
  const upload = await prisma.upload.create({
    data: {
      userId,
      campaignId,
      fileKey,
      status: 'pending',
      metadata,
    },
  });

  res.status(201).json({
    success: true,
    data: upload,
  });
}

module.exports = { initiateUpload, completeUpload };
```

### 5. Routes Configuration

```javascript
// routes/uploadRoutes.js
const express = require('express');
const router = express.Router();
const { initiateUpload, completeUpload } = require('../controllers/uploadController');
const authMiddleware = require('../middleware/auth');

router.post('/initiate', authMiddleware, initiateUpload);
router.post('/complete', authMiddleware, completeUpload);

module.exports = router;
```

## Mobile App Configuration

The mobile app is already configured! It uses:

```dart
// lib/core/config.dart
class AppConfig {
  static const String apiBaseUrl = "https://visual-data-api.onrender.com/v1";
}

// The app automatically:
// 1. Calls /uploads/initiate to get presigned URL
// 2. Uploads directly to R2 using HTTP PUT
// 3. Calls /uploads/complete to finalize
```

## Custom Domain Setup (Optional)

### 1. Connect Domain to R2

```bash
# In Cloudflare Dashboard → R2 → Your Bucket
1. Click "Settings"
2. Scroll to "Public access"
3. Click "Connect domain"
4. Enter your domain (e.g., cdn.yourdomain.com)
5. Click "Connect domain"
```

### 2. Update Backend

```env
R2_PUBLIC_URL=https://cdn.yourdomain.com
```

### 3. Generate Public URLs

```javascript
function getPublicUrl(fileKey) {
  return `${process.env.R2_PUBLIC_URL}/${fileKey}`;
}
```

## Security Best Practices

### 1. CORS Configuration

```javascript
// Configure CORS for R2 bucket
// In Cloudflare Dashboard → R2 → Your Bucket → Settings → CORS policy

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

### 2. Validation

```javascript
// Validate file before generating presigned URL
function validateUpload(fileName, mimeType, fileSize) {
  // Check MIME type
  const allowedTypes = process.env.ALLOWED_MIME_TYPES.split(',');
  if (!allowedTypes.includes(mimeType)) {
    throw new Error('Invalid file type');
  }

  // Check file size
  if (fileSize > parseInt(process.env.MAX_FILE_SIZE)) {
    throw new Error('File too large');
  }

  // Check file extension
  const ext = fileName.split('.').pop().toLowerCase();
  const allowedExts = ['jpg', 'jpeg', 'png', 'heic', 'webp'];
  if (!allowedExts.includes(ext)) {
    throw new Error('Invalid file extension');
  }

  return true;
}
```

### 3. Rate Limiting

```javascript
const rateLimit = require('express-rate-limit');

const uploadLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 50, // 50 uploads per window
  message: 'Too many uploads, please try again later',
});

router.post('/initiate', authMiddleware, uploadLimiter, initiateUpload);
```

## Testing R2 Integration

### 1. Test with cURL

```bash
# Get presigned URL
curl -X POST https://your-api.com/v1/uploads/initiate \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "campaignId": "campaign_id",
    "fileName": "test.jpg",
    "mimeType": "image/jpeg"
  }'

# Upload file to presigned URL
curl -X PUT "PRESIGNED_URL_FROM_ABOVE" \
  -H "Content-Type: image/jpeg" \
  --data-binary @test.jpg

# Complete upload
curl -X POST https://your-api.com/v1/uploads/complete \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "campaignId": "campaign_id",
    "fileKey": "FILE_KEY_FROM_INITIATE",
    "metadata": {
      "latitude": 37.7749,
      "longitude": -122.4194
    }
  }'
```

### 2. Test with Mobile App

1. Run the mobile app
2. Login
3. Navigate to a campaign
4. Tap "Upload Photos"
5. Select a photo from gallery or camera
6. Tap "Upload"
7. Watch progress bar
8. Check success message

## Monitoring & Analytics

### 1. R2 Metrics

```bash
# In Cloudflare Dashboard → R2 → Your Bucket → Metrics
- Total storage used
- Number of objects
- Class A operations (writes)
- Class B operations (reads)
```

### 2. Backend Logging

```javascript
// Log upload events
console.log('Upload initiated:', {
  userId,
  campaignId,
  fileKey,
  fileSize,
  timestamp: new Date(),
});

console.log('Upload completed:', {
  uploadId,
  status: 'success',
  duration: Date.now() - startTime,
});
```

## Cost Estimation

Cloudflare R2 Pricing:
- **Storage**: $0.015 per GB/month
- **Class A Operations** (writes): $4.50 per million
- **Class B Operations** (reads): $0.36 per million
- **Egress**: FREE (no data transfer costs!)

Example for 10,000 uploads/month:
- 10,000 photos × 2MB average = 20GB storage = $0.30/month
- 30,000 operations (initiate + upload + complete) = $0.14/month
- **Total: ~$0.44/month** (plus backend costs)

## Troubleshooting

### Common Issues

**1. CORS Errors**
- Ensure CORS is configured on R2 bucket
- Check AllowedOrigins includes your domain

**2. Presigned URL Expired**
- Check PRESIGNED_URL_EXPIRY is sufficient
- Default 1 hour should be plenty

**3. Upload Fails**
- Verify file size < MAX_FILE_SIZE
- Check MIME type is allowed
- Ensure presigned URL hasn't expired

**4. File Not Found After Upload**
- Verify fileKey matches exactly
- Check bucket name is correct
- Ensure upload completed successfully

### Debug Mode

```javascript
// Enable AWS SDK debug logging
process.env.AWS_SDK_JS_SUPPRESS_MAINTENANCE_MODE_MESSAGE = '1';
process.env.DEBUG = 'aws-sdk:*';
```

## Additional Resources

- [Cloudflare R2 Documentation](https://developers.cloudflare.com/r2/)
- [AWS SDK for JavaScript v3](https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/)
- [Presigned URLs Guide](https://docs.aws.amazon.com/AmazonS3/latest/userguide/PresignedUrlUploadObject.html)

## Summary

The DataSet Mobile app is fully compatible with Cloudflare R2:

✅ **Mobile App**: Already implements three-step upload flow
✅ **Backend**: Needs R2 credentials and presigned URL generation
✅ **Storage**: Cloudflare R2 with S3-compatible API
✅ **Security**: Presigned URLs with expiry
✅ **Cost**: Extremely low with zero egress fees

Follow the backend configuration steps above to complete the integration!
