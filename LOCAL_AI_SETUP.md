# 🤖 Local AI with Gemma - Setup Guide

## Overview

Your DishDiary app now runs AI **completely locally** on your device using Google's Gemma 2B model through MediaPipe Tasks. 

### ✨ Benefits

- ✅ **No API keys required** - Works without any paid services
- ✅ **100% offline** - After initial download, works without internet
- ✅ **Privacy-first** - Your data never leaves your device
- ✅ **No ongoing costs** - Free forever after download
- ✅ **Same features** - Recipe generation, YouTube extraction, cooking Q&A

### ⚠️ Requirements

- **Storage**: ~1.5GB for the model file
- **RAM**: 2-3GB available memory
- **Android**: API 24+ (Android 7.0+)
- **iOS**: iPhone 8 or newer (if iOS support is added)
- **Processor**: ARM64 (most modern phones) or x86_64 (emulators)

---

## Quick Start

### 1. First Launch - Manual Model Installation Required

The Gemma model requires **manual download** because it's a gated model on Hugging Face (requires license acceptance).

**Steps to Install:**

1. **Open Settings** in the app
2. **Find "LOCAL AI (GEMMA)"** section at the top
3. **Tap "Setup Instructions"** button
4. **Follow the 3 steps**:
   - **Step 1**: Visit https://huggingface.co/litert-community/Gemma2-2B-IT
   - **Step 2**: Accept the Gemma license & download `Gemma2-2B-IT_seq128_q8_ekv1280.tflite`
   - **Step 3**: Copy the file to the path shown in the app
5. **Restart the app** - status will change to **"READY"** ✅

### Alternative: Using ADB (for developers)

If you have ADB set up, you can push the file directly:

```bash
adb push Gemma2-2B-IT_seq128_q8_ekv1280.tflite /data/data/com.example.dishdiary/files/models/
```

### 2. Using Local AI

Once the model is downloaded:

1. Go to **AI Recipe Chef** (chatbot screen)
2. Type your recipe request (e.g., "Make a chocolate cake recipe")
3. The AI runs locally - no internet needed!
4. Responses take ~5-15 seconds (slower than cloud, but free!)

---

## Model Management

### Download the Model

**From Settings screen:**
- Tap the **"Download Model"** button
- Review the confirmation dialog
- Watch the progress bar
- Wait for completion notification

**Important:** 
- Don't close the app during download
- Keep your screen on
- Stable Wi-Fi recommended

### Check Model Status

The settings screen shows:
- **Model size** - Shows "1.5 GB (installed)" when ready
- **Status badge** - Green "READY" or orange "SETTING UP"
- **Info text** - Current state of the AI

### Delete the Model

To free up 1.5GB of storage:

1. Go to **Settings**
2. Scroll to **"LOCAL AI (GEMMA)"** section
3. Tap the **trash icon** next to the model info
4. Confirm deletion

**Note:** You'll need to download again to use AI features.

---

## Performance Expectations

### Speed

| Task | Cloud (Mistral) | Local (Gemma) |
|------|--------------|---------------|
| Recipe generation | 1-3 seconds | 5-15 seconds |
| Conversational answer | 1-2 seconds | 3-8 seconds |
| YouTube extraction | 10-20 seconds | 15-30 seconds |

**Why slower?** Running on device CPU instead of powerful cloud servers.

### Quality

- Gemma 2B is **good** for recipe generation and cooking Q&A
- Not as smart as GPT-4 or Claude, but **perfectly capable** for cooking tasks
- Responses are **detailed and accurate** for culinary queries

---

## Troubleshooting

### "AI service is not available"

**Cause:** Model not downloaded or still initializing

**Fix:**
1. Go to Settings
2. Check the LOCAL AI section
3. If orange "SETTING UP", wait for initialization
4. If not downloaded, tap "Download Model"

### Download stuck or failing

**Symptoms:**
- Progress bar not moving
- Download takes hours
- Error message appears

**Solutions:**
1. Check your internet connection
2. Ensure you have 2GB+ free storage
3. Restart the app and try again
4. Clear app cache (Android Settings > Apps > DishDiary > Clear Cache)

### AI response very slow (>30 seconds)

**Causes:**
- Older device with less RAM
- Too many apps running
- Model too large for your device

**Solutions:**
1. Close other apps before using AI
2. Restart your device
3. Consider using cloud AI if your device struggles

### Out of memory crashes

**Symptoms:**
- App crashes during AI generation
- "Out of memory" errors

**Fix:**
1. Delete the model from Settings
2. Close all background apps
3. Restart your device
4. Re-download the model
5. Try again with fewer apps running

### Model takes too long to download

**Normal times:**
- Fast Wi-Fi (50 Mbps): 3-5 minutes
- Medium Wi-Fi (20 Mbps): 8-12 minutes
- Slow Wi-Fi (10 Mbps): 15-25 minutes
- Mobile data: Varies (not recommended - uses lots of data!)

**If stuck:**
1. Check network connection
2. Try a different Wi-Fi network
3. Restart download (delete partial file first)

---

## Migration from Mistral API

### What Changed

**Before (Mistral):**
- Required API key from mistral.ai
- Worked fast but needed internet
- Had daily request limits
- Cost money at scale

**Now (Gemma Local):**
- No API key needed
- Works offline after download
- Unlimited requests
- Completely free

### Do You Need to Do Anything?

**No action required!** The app automatically uses local AI now.

**Optional:**
- You can still keep your Mistral API key in settings if you want
- The app prioritizes local Gemma AI
- Mistral service is still available as a cloud fallback

---

## Technical Details

### How It Works

1. **MediaPipe Tasks** - Google's framework for on-device ML
2. **Gemma 2B IT** - Instruction-tuned language model (2 billion parameters)
3. **Quantization** - Float16 format for mobile efficiency
4. **Local inference** - Runs on CPU, no GPU required

### File Locations

**Android:**
```
/data/data/com.example.dishdiary/files/models/gemma-2-2b-it.tflite
```

**iOS:**
```
/Documents/models/gemma-2-2b-it.tflite
```

### Model Source

- Official MediaPipe-hosted model
- URL: `https://storage.googleapis.com/mediapipe-models/gemma-2/gemma-2-2b-it/float16/1/gemma-2-2b-it.tflite`
- Licensed under Google's Gemma license

### Dependencies Added

```yaml
# pubspec.yaml
mediaPipeTasksGenai: ^0.2.0  # MediaPipe AI inference
path: ^1.8.3                  # Path manipulation
```

### Android Changes

- **minSdk** raised from 21 to **24** (MediaPipe requirement)
- Native library filters: `arm64-v8a`, `x86_64`
- Core library desugaring enabled

---

## Limitations

### What Gemma Can Do Well

✅ Generate recipes from text prompts
✅ Answer cooking questions
✅ Extract recipes from YouTube transcripts
✅ Provide cooking tips and techniques
✅ Suggest ingredient substitutions

### What Gemma Struggles With

❌ Very long conversations (>2000 tokens)
❌ Extremely complex multi-recipe planning
❌ Real-time web search (no Tavily integration yet)
❌ Image recognition (can't analyze food photos)

### When to Use Cloud AI Instead

Consider using Mistral/cloud fallback if:
- You need faster responses
- Your device can't handle local AI
- You want higher-quality models (Gemma 7B, etc.)

---

## Future Enhancements

### Planned

- [ ] Streaming responses (show text as it generates)
- [ ] Model selection (choose between Gemma 300M / 2B / 7B)
- [ ] Web search integration with local AI
- [ ] Recipe image generation
- [ ] Voice input/output integration

### Possible

- Hybrid mode (local first, cloud fallback)
- Multiple model support
- Quantization options (faster vs. quality tradeoff)
- On-device fine-tuning based on your preferences

---

## Support

### Common Questions

**Q: Does this work without internet?**
A: Yes! After the initial 1.5GB download, everything works offline.

**Q: Will this drain my battery?**
A: AI generation uses CPU, so expect 5-10% battery per 100 queries. Normal usage is minimal impact.

**Q: Can I use a larger model?**
A: Not currently. Gemma 7B+ requires 4GB+ RAM which many phones don't have available.

**Q: Is my data private?**
A: 100% private. All processing happens on your device. Nothing is sent to any server.

**Q: Why not use Ollama or other local AI?**
A: MediaPipe has the best Flutter integration and is optimized for mobile CPUs.

### Getting Help

If you experience issues:
1. Check the Troubleshooting section above
2. Go to Settings > LOCAL AI section
3. Check model status and error messages
4. Try deleting and re-downloading the model
5. Restart your device if needed

---

## License & Credits

- **Gemma Model**: Google LLC (Gemma License)
- **MediaPipe Tasks**: Google LLC (Apache 2.0)
- **Integration**: Custom implementation for DishDiary

---

**Last Updated**: April 2026
**Version**: 1.0.0
