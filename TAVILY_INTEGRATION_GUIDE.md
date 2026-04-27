# Tavily API Integration Guide

This document explains the integration of Tavily API for the AI Chef feature in DishDiary.

## Overview

DishDiary now uses **two API keys** for different AI features:

### 1. Mistral API Key
- **Used for**: YouTube recipe extraction & general AI conversations
- **Sign up**: https://console.mistral.ai/api-keys/
- **Free tier**: Generous free tier available
- **Required for**: Basic AI features

### 2. Tavily API Key
- **Used for**: AI Chef web-grounded recipe generation
- **Sign up**: https://app.tavily.com
- **Free tier**: 1,000 searches/month (no credit card needed)
- **Required for**: Accurate, web-grounded AI Chef recipes

## How to Get API Keys

### Getting Mistral API Key

1. Visit: https://console.mistral.ai/api-keys/
2. Sign up or log in
3. Create a new API key
4. Copy the key
5. Paste it in the app during signup or in Settings

### Getting Tavily API Key

1. Visit: https://app.tavily.com
2. Sign up (no credit card required)
3. Navigate to the API section in your dashboard
4. Copy your API key (starts with `tvly-`)
5. Paste it in the app during signup or in Settings

## Where to Add API Keys

### During Sign Up
1. Create a new account
2. Expand the "AI Chef Features" section
3. Enter your Mistral and/or Tavily API keys (optional)
4. Complete signup

### After Sign Up (Settings)
1. Go to Settings screen
2. Tap the app version (in About section) 5 times to reveal API settings
3. Enter your Mistral API key
4. Enter your Tavily API key
5. Save each key separately

## What Happens Without API Keys?

### Without Mistral API Key
- A default or previously stored API key is required
- You can use YouTube recipe extraction
- General AI conversations work

### Without Tavily API Key
- AI Chef will still work but uses only the LLM's internal knowledge
- No web-grounded, up-to-date recipe information
- Less accurate for specific dietary requirements or trending recipes

## Technical Implementation

### Files Modified

1. **`lib/models/user.dart`**
   - Added `mistralApiKey` and `tavilyApiKey` fields

2. **`lib/services/auth_service.dart`**
   - Added methods to save/get/delete both API keys
   - Updated `signUp` to accept API keys

3. **`lib/services/mistral_service.dart`**
   - Integrated Tavily API for web search
   - Uses Tavily for recipe grounding when generating recipes from prompts
   - Falls back to LLM knowledge if no Tavily key is provided

4. **`lib/providers/providers.dart`**
   - Added `tavilyApiKeyProvider`
   - Updated `mistralServiceProvider` to pass Tavily key

5. **`lib/features/auth/signup_screen.dart`**
   - Added optional API key input section
   - Added help dialog explaining how to get keys

6. **`lib/features/settings/settings_screen.dart`**
   - Separate cards for Mistral and Tavily API keys
   - Updated help dialog with both API key guides

## API Usage

### Tavily API Search

The Tavily API is called when:
- User asks AI Chef to generate a recipe
- The intent is classified as a recipe request
- A Tavily API key is configured

Example search query transformation:
- User input: "Can you make me a chocolate cake recipe?"
- Tavily query: "chocolate cake recipe"

### Response Format

Tavily returns:
- Direct answer (AI-generated summary)
- Search results with content snippets
- URLs to source pages

This data is then passed to Mistral's LLM to generate a structured recipe JSON.

## Troubleshooting

### "No Tavily key" warning in console
- This is normal if you haven't added a Tavily API key
- AI Chef will use LLM knowledge only

### Tavily API errors
- Check if your API key is correct (starts with `tvly-`)
- Ensure you haven't exceeded the 1,000 searches/month limit
- Verify your internet connection

### Recipe generation is slow
- Tavily API call adds ~2-3 seconds
- This is normal for web-grounded generation
- The result is more accurate and up-to-date

## Cost & Limits

### Mistral
- Free tier: Generous free tier, no credit card needed
- Paid plans available for higher limits
- Check https://console.mistral.ai for more info

### Tavily
- **Free tier**: 1,000 searches/month
- No credit card required for free tier
- Paid plans start at $19/month for 10,000 searches
- Check https://tavily.com/pricing for details

## Security

- API keys are stored securely using `flutter_secure_storage`
- Keys are stored locally on your device only
- Keys are not shared with any third-party servers except the respective API providers
- You can delete your API keys at any time from Settings

## Support

For issues or questions:
1. Check the console logs for error messages
2. Verify your API keys are correct
3. Ensure you have an active internet connection
4. Check the API provider status pages for outages
