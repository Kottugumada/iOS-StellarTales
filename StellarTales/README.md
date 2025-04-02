## Configuration

The app requires API keys for NASA and Google Gemini services. To set up:

1. Copy `Config/ConfigTemplate.swift` to `Config/Config.swift`
2. Replace the placeholder API keys in `Config.swift` with your actual keys:
   - NASA API key: Get from https://api.nasa.gov
   - Gemini API key: Get from https://makersuite.google.com/app/apikey

Note: `Config.swift` is git-ignored to keep API keys secure. Never commit your actual API keys to version control.

### API Keys
- NASA API: Required for astronomy picture of the day (APOD)
- Gemini API: Required for AI-generated content about celestial objects 