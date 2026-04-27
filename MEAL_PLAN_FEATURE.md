# Weekly Meal Prep Feature Guide

## Overview

The **Weekly Meal Prep** feature allows users to plan their entire week's meals with AI-powered recipe recommendations. The feature uses **Mistral AI** combined with **Tavily API** for web-grounded recipe searches, ensuring you get the best, most up-to-date recipes from the internet.

## Features

### 🎯 Core Capabilities

1. **AI-Powered Meal Planning**
   - Personalized weekly meal plans based on your preferences
   - Web-grounded recipe search using Tavily API
   - Nutrition-balanced meal recommendations
   - Supports multiple dietary preferences and restrictions

2. **Interactive Questionnaire**
   - Step-by-step preference collection
   - Servings customization
   - Health goals selection (weight loss, muscle gain, maintenance)
   - Dietary preferences (vegetarian, vegan, keto, etc.)
   - Favorite cuisines selection
   - Ingredient exclusions

3. **Weekly Meal Plan View**
   - Calendar-like interface showing all 7 days
   - Daily nutrition summary (calories, protein, carbs, fat)
   - Easy day-to-day navigation
   - Meal type organization (breakfast, lunch, dinner, snacks)

4. **Shopping List Generator**
   - Automatic shopping list from meal plan
   - Grouped by categories
   - Check-off items while shopping
   - Shareable shopping list
   - Shows which meals need each ingredient

5. **Meal Plan Editor**
   - Swap meals with your existing recipes
   - Add custom meals not in your recipe collection
   - Edit or remove any meal
   - Add snacks throughout the day

## How to Use

### Creating Your First Meal Plan

1. **Access the Feature**
   - From the home screen, tap the **"Weekly Meal Plan"** card
   - Or navigate to the meal plan section from the app menu

2. **Complete the Questionnaire**

   **Step 1: Servings**
   - Select how many people you're cooking for
   - Use the + and - buttons to adjust

   **Step 2: Health Goals**
   - Choose your primary health objective:
     - Weight Loss
     - Muscle Gain
     - Maintenance
     - More Energy
     - Healthy Eating
   - Optionally set a target daily calorie goal

   **Step 3: Dietary Preferences**
   - Select all that apply:
     - Vegetarian
     - Vegan
     - High-Protein
     - Low-Carb
     - Keto
     - Paleo
     - Gluten-Free
     - Dairy-Free
     - Mediterranean

   **Step 4: Cuisines & Exclusions**
   - Pick your favorite cuisines (Italian, Mexican, Asian, etc.)
   - Add any ingredients you want to exclude
   - Tap "Generate Meal Plan" when ready

3. **AI Generation Process**
   - The AI will search the web using Tavily API for relevant recipes
   - It analyzes nutrition data and your preferences
   - Creates a balanced 7-day meal plan
   - This takes about 15-30 seconds

4. **Review Your Meal Plan**
   - View all 7 days of meals
   - Check daily nutrition summaries
   - Browse breakfast, lunch, dinner, and snacks

### Editing Your Meal Plan

1. **Tap "Edit Plan"** from the meal plan view

2. **Navigate Between Days**
   - Use the day selector at the top
   - Each day shows meal availability with a green dot

3. **Modify Meals**
   - **Add a Meal**: Tap the "+" on any empty meal slot
   - **Edit a Meal**: Tap on any existing meal
   - **Remove a Meal**: Tap the edit icon, then delete

4. **Choose Meal Source**
   - **From Your Recipes**: Select from recipes you've created
   - **Custom Meal**: Create a meal not in your collection
     - Enter meal name and emoji
     - Add nutrition information
     - List ingredients for shopping list

5. **Save Changes**
   - Tap the save icon in the top right
   - Your changes are automatically stored

### Using the Shopping List

1. **Access Shopping List**
   - Tap the shopping cart icon from the meal plan view

2. **View Items**
   - See all ingredients needed for the week
   - Items are grouped by meal
   - Shows quantity needed

3. **Manage Items**
   - **Check Off**: Tap the circle to mark items as purchased
   - **Add Item**: Use the FAB to add items not in the plan
   - **Remove Item**: Swipe left to delete
   - **Clear Checked**: Use the trash icon to remove all checked items

4. **Share List**
   - Tap the share icon
   - Send to family members or use while shopping

## Technical Details

### API Requirements

To use the AI-powered meal planning feature, you need:

1. **Mistral API Key**
   - Required for AI meal generation
   - Sign up at: https://console.mistral.ai/api-keys/
   - Generous free tier available

2. **Tavily API Key** (Recommended)
   - Enables web-grounded recipe searches
   - Sign up at: https://app.tavily.com
   - Free tier: 1,000 searches/month
   - Without this, AI uses its internal knowledge base

### Adding API Keys

1. Go to **Settings** in the app
2. Find the **API Configuration** section
3. Enter your Mistral API key
4. Enter your Tavily API key (optional but recommended)
5. Save changes

### Data Storage

- Meal plans are stored locally using **Isar Database**
- Each meal plan includes:
  - 7 days of meals (breakfast, lunch, dinner, snacks)
  - Nutrition information per meal
  - Complete shopping list
  - User preferences used for generation
- Plans are associated with your user account

## Files Created

### Models
- `lib/models/meal_plan.dart` - Main meal plan data structures
  - `MealPlan` - Weekly plan container
  - `DayPlan` - Individual day's meals
  - `ScheduledMeal` - Single meal entry
  - `ShoppingListItem` - Shopping list items
  - `MealType` - Enum for meal categories

### Services
- `lib/services/meal_plan_service.dart` - AI meal generation logic
  - Web search integration with Tavily
  - Recipe parsing and structuring
  - Shopping list generation

### Screens
- `lib/features/meal_plan/meal_plan_questionnaire_screen.dart` - Preference collection
- `lib/features/meal_plan/meal_plan_generation_screen.dart` - AI generation with loading states
- `lib/features/meal_plan/weekly_meal_plan_screen.dart` - Main meal plan viewer
- `lib/features/meal_plan/meal_plan_detail_screen.dart` - Meal plan editor
- `lib/features/meal_plan/meal_selector_screen.dart` - Recipe/custom meal selector
- `lib/features/meal_plan/shopping_list_screen.dart` - Shopping list manager

### Updated Files
- `lib/services/local_storage_service.dart` - Added meal plan CRUD operations
- `lib/providers/providers.dart` - Added meal plan providers
- `lib/features/home/modern_home_screen.dart` - Added meal plan quick action card
- `pubspec.yaml` - Added `share_plus` dependency

## Tips for Best Results

1. **Be Specific with Preferences**
   - The more specific you are, the better the AI can tailor recommendations
   - Exclude ingredients you genuinely dislike or are allergic to

2. **Use Tavily API**
   - Enables real-time web searches for current recipes
   - Provides more variety and up-to-date meal ideas

3. **Review Nutrition Goals**
   - Set realistic calorie targets based on your goals
   - The AI balances macros across the day

4. **Customize After Generation**
   - Don't like a meal? Swap it with your own recipes
   - Add family favorites that aren't in your recipe collection

5. **Plan for Leftovers**
   - The AI sometimes suggests meals that can use leftovers
   - Reduces cooking time and food waste

## Troubleshooting

### "API Key Required" Error
- Make sure you've added your Mistral API key in Settings
- Keys are stored securely in flutter_secure_storage

### No Recipes Found When Editing
- Create some recipes first using the recipe creation feature
- Or use the "Custom Meal" option to add meals manually

### Meal Generation Takes Too Long
- Web searches can take 15-30 seconds
- If it times out, check your internet connection
- Try again or reduce the complexity of your preferences

### Shopping List Missing Items
- Some custom meals may not have complete ingredient lists
- You can manually add missing items to the shopping list

## Future Enhancements

Potential improvements for future versions:

- [ ] Meal plan templates (quick start with popular plans)
- [ ] Export meal plan as PDF
- [ ] Share meal plan with family
- [ ] Integration with grocery delivery services
- [ ] Meal prep instructions (batch cooking guides)
- [ ] Calorie tracking across the week
- [ ] Recipe substitution suggestions
- [ ] Seasonal meal recommendations
- [ ] Budget-friendly meal options
- [ ] Multiple meal plans (save several plans)

## Privacy & Data

- All meal plans are stored locally on your device
- API keys are encrypted and stored securely
- No meal plan data is sent to external servers (except for AI generation)
- Tavily searches are anonymized
- You can delete meal plans at any time

---

**Enjoy your personalized meal planning!** 🍽️

For questions or issues, please refer to the main app documentation or contact support.
