# Deployment Guide

## Prerequisites

- Flutter 3.0+ installed
- Git configured
- Account on deployment platform (GitHub, Vercel, Firebase, etc.)

## Local Testing

### Build Web
\`\`\`bash
flutter build web --release
\`\`\`

### Serve Locally
\`\`\`bash
# Using Python 3
cd build/web
python -m http.server 8000

# Using Node.js
npx http-server build/web
\`\`\`

Visit `http://localhost:8000` in your browser.

## GitHub Pages Deployment

### Setup

1. Create GitHub repository
2. Push code to main branch

### Deploy

\`\`\`bash
# Build for web
flutter build web --release

# Create gh-pages branch
git checkout --orphan gh-pages
git rm -rf .

# Copy build output
cp -r build/web/* .
git add .
git commit -m "Deploy biometrics dashboard"

# Push to gh-pages
git push origin gh-pages

# Return to main branch
git checkout main
\`\`\`

### Configure Repository

1. Go to Settings → Pages
2. Set source to `gh-pages` branch
3. Wait for deployment to complete
4. Access at `https://username.github.io/biometrics-dashboard`

## Vercel Deployment

### Setup

\`\`\`bash
# Install Vercel CLI
npm i -g vercel

# Login to Vercel
vercel login
\`\`\`

### Deploy

\`\`\`bash
# Build for web
flutter build web --release

# Deploy
vercel --prod
\`\`\`

### Configure

1. Create `vercel.json`:
\`\`\`json
{
  "buildCommand": "flutter build web --release",
  "outputDirectory": "build/web",
  "env": {
    "FLUTTER_WEB": "true"
  }
}
\`\`\`

2. Push to GitHub
3. Vercel will auto-deploy on push

## Firebase Hosting

### Setup

\`\`\`bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize project
firebase init hosting
\`\`\`

### Deploy

\`\`\`bash
# Build for web
flutter build web --release

# Deploy
firebase deploy --only hosting
\`\`\`

### Configure

1. Edit `firebase.json`:
\`\`\`json
{
  "hosting": {
    "public": "build/web",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
\`\`\`

## Docker Deployment

### Build Image

\`\`\`dockerfile
FROM nginx:alpine
COPY build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
\`\`\`

### Build and Run

\`\`\`bash
# Build Flutter web
flutter build web --release

# Build Docker image
docker build -t biometrics-dashboard .

# Run container
docker run -p 8080:80 biometrics-dashboard
\`\`\`

### Push to Registry

\`\`\`bash
# Tag image
docker tag biometrics-dashboard username/biometrics-dashboard:latest

# Push to Docker Hub
docker push username/biometrics-dashboard:latest
\`\`\`

## Performance Optimization

### Enable Compression

\`\`\`bash
# Build with compression
flutter build web --release --dart-define=FLUTTER_WEB_USE_SKIA=true
\`\`\`

### Optimize Assets

\`\`\`bash
# Minify JavaScript
flutter build web --release --dart-define=FLUTTER_WEB_CANVASKIT_URL=https://cdn.jsdelivr.net/npm/canvaskit-wasm@0.37.0/bin/
\`\`\`

### CDN Configuration

For Vercel/Firebase, enable automatic CDN caching:
- Static assets: 1 year
- HTML: 1 hour
- API responses: 5 minutes

## Monitoring

### Error Tracking

1. **Sentry Integration**:
\`\`\`dart
import 'package:sentry_flutter/sentry_flutter.dart';

await SentryFlutter.init(
  (options) => options.dsn = 'YOUR_SENTRY_DSN',
  appRunner: () => runApp(const MyApp()),
);
\`\`\`

2. **Firebase Crashlytics**:
\`\`\`dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

FirebaseCrashlytics.instance.recordFlutterError(details);
\`\`\`

### Performance Monitoring

1. **Firebase Performance**:
\`\`\`dart
import 'package:firebase_performance/firebase_performance.dart';

final trace = FirebasePerformance.instance.newTrace('chart_render');
trace.start();
// ... render chart ...
trace.stop();
\`\`\`

## Rollback

### GitHub Pages
\`\`\`bash
git revert <commit-hash>
git push origin main:gh-pages
\`\`\`

### Vercel
- Use Vercel dashboard to rollback to previous deployment

### Firebase
\`\`\`bash
firebase hosting:channel:deploy <channel-name>
firebase hosting:clone <source-site> <target-site>
\`\`\`

## Troubleshooting

### Build Fails
\`\`\`bash
# Clean build
flutter clean
flutter pub get
flutter build web --release
\`\`\`

### Deployment Fails
- Check build output for errors
- Verify all dependencies are installed
- Check platform-specific requirements

### Performance Issues
- Enable performance overlay: `showPerformanceOverlay: true`
- Profile with DevTools
- Check network tab for slow requests

## Maintenance

### Regular Updates
\`\`\`bash
# Update Flutter
flutter upgrade

# Update dependencies
flutter pub upgrade

# Run tests
flutter test
\`\`\`

### Monitoring Checklist
- [ ] Error rates normal
- [ ] Performance metrics stable
- [ ] User feedback positive
- [ ] Dependencies up to date
- [ ] Security patches applied
