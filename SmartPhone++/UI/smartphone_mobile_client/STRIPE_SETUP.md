# Stripe Payment Integration Setup

## Prerequisites
1. A Stripe account (https://stripe.com)
2. Flutter project with the required dependencies

## Required Dependencies
Make sure these are in your `pubspec.yaml`:
```yaml
dependencies:
  flutter_stripe: ^10.1.1
  flutter_form_builder: ^10.1.0
  form_builder_validators: ^11.2.0
  flutter_dotenv: ^5.1.0
  http: ^1.4.0
```

## Environment Configuration
Create a `.env` file in your project root with:
```
STRIPE_SECRET_KEY=sk_test_your_stripe_secret_key_here
STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_publishable_key_here
```

## Stripe Keys Setup
1. Go to your Stripe Dashboard
2. Navigate to Developers > API keys
3. Copy your Publishable key and Secret key
4. Replace the placeholder values in your `.env` file

## Android Configuration
Make sure your `MainActivity.kt` extends `FlutterFragmentActivity`:
```kotlin
class MainActivity : FlutterFragmentActivity()
```

And your theme uses Material Design:
```xml
<style name="LaunchTheme" parent="Theme.MaterialComponents.Light.NoActionBar">
<style name="NormalTheme" parent="Theme.MaterialComponents.Light.NoActionBar">
```

## Usage
The Stripe payment screen is now integrated into your cart checkout flow. When users click "Proceed to Checkout", they'll be taken to the payment screen where they can:

1. Review their order summary
2. Fill in billing information (pre-filled with user data)
3. Complete payment using Stripe
4. Have their cart automatically cleared after successful payment

## Testing
- Use Stripe test card numbers for testing
- Test card: 4242 4242 4242 4242
- Expiry: Any future date
- CVC: Any 3 digits
- ZIP: Any 5 digits

## Security Notes
- Never commit your `.env` file to version control
- Use test keys for development
- Switch to live keys only for production
- The secret key is used server-side in production apps
