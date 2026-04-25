# BrailleApp

iOS app that captures Braille images and converts them to English text using the Braille Recognition API.

## Requirements

- iOS 18.5+
- Xcode 16.4+

## Installation

1. Open `BrailleApp.xcodeproj` in Xcode

2. Set API URL in `BrailleApp/Info.plist`:
   - Key: `API_BASE_URL`
   - Value: `http://your-api-server:8000`

3. Build and run (⌘ + R)

## Usage

1. Grant camera permission
2. Point camera at Braille text
3. View English translation

## API Configuration

The app calls `[API_BASE_URL]/predict/` with the captured image.

## Troubleshooting

- **Connection failed**: Check `API_BASE_URL` in Info.plist
- **Local testing**: Use your computer's IP address, not `localhost`