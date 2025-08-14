# Webshop Feature

## Overview
The webshop feature has been added to the mobile client, allowing users to browse and purchase products from the database.

## Features
- **Product Display**: Shows all active products from the database in a grid layout
- **Product Information**: Displays product name, brand, category, and price
- **Product Images**: Shows product images from the database (base64 encoded)
- **Add to Cart**: Each product has an "Add to Cart" button (currently shows a success message)
- **Responsive Design**: Grid layout that adapts to different screen sizes
- **Error Handling**: Graceful handling of loading states and errors
- **Pull to Refresh**: Users can pull down to refresh the product list

## Navigation
- Added a new "Webshop" tab in the bottom navigation bar
- Uses a shopping bag icon to represent the webshop
- Positioned between Home and Profile tabs

## API Integration
- Connects to the ProductController API endpoints
- Fetches active products from `/Product/active`
- Supports additional endpoints for featured products, category filtering, etc.

## Product Model
The screen uses the existing Product model which includes:
- Basic product information (name, description, price)
- Brand and category details
- Product images (base64 encoded)
- Stock information (not displayed to users as requested)

## Future Enhancements
- Implement actual cart functionality
- Add product search and filtering
- Product detail pages
- Shopping cart management
- Checkout process

## Configuration
Update the `_baseUrl` in `lib/services/product_service.dart` to point to your actual API server.

## Dependencies
- http: ^1.4.0 (for API calls)
- json_annotation: ^4.8.1 (for JSON serialization)
- All other dependencies are already included in the project
