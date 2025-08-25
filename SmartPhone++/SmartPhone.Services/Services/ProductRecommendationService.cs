using Microsoft.EntityFrameworkCore;
using SmartPhone.Model.Responses;
using SmartPhone.Services.Database;
using SmartPhone.Services.Interfaces;
using MapsterMapper;

namespace SmartPhone.Services.Services
{
    public class ProductRecommendationService : IProductRecommendationService
    {
        private readonly SmartPhoneDbContext _context;
        private readonly IMapper _mapper;

        public ProductRecommendationService(SmartPhoneDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

            public async Task<List<ProductResponse>> GetRecommendationsForUserAsync(int userId, int maxRecommendations = 3)
    {
        try
        {
            // Get the user's cart and cart items from the database
            var userCart = await _context.Carts
                .Include(c => c.CartItems)
                    .ThenInclude(ci => ci.Product)
                        .ThenInclude(p => p.Category)
                .Include(c => c.CartItems)
                    .ThenInclude(ci => ci.Product)
                        .ThenInclude(p => p.ProductImages)
                .FirstOrDefaultAsync(c => c.UserId == userId && c.IsActive);

            if (userCart?.CartItems == null || !userCart.CartItems.Any())
            {
                // If no cart items, return featured products
                return await GetFeaturedRecommendationsAsync(new List<int>(), maxRecommendations);
            }

            // Extract data from cart items
            var cartItemProductIds = userCart.CartItems.Select(ci => ci.ProductId).ToList();
            var cartItemProductNames = userCart.CartItems.Select(ci => ci.Product.Name).ToList();
            var cartItemCategoryIds = userCart.CartItems.Select(ci => ci.Product.CategoryId).ToList();

            // Use the existing logic to get recommendations
            return await GetRecommendationsAsync(cartItemProductIds, cartItemProductNames, cartItemCategoryIds, maxRecommendations);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error getting recommendations for user {userId}: {ex.Message}");
            return new List<ProductResponse>();
        }
    }

    public async Task<List<ProductResponse>> GetRecommendationsAsync(
        List<int> cartItemProductIds,
        List<string> cartItemProductNames,
        List<int> cartItemCategoryIds,
        int maxRecommendations = 3)
    {
        var recommendations = new List<ProductResponse>();

        try
        {
            // Rule 1: Find products with similar names (cases, glass, accessories)
            var nameBasedRecommendations = await GetNameBasedRecommendationsAsync(
                cartItemProductNames, cartItemProductIds, maxRecommendations / 2);
            recommendations.AddRange(nameBasedRecommendations);

            // Rule 2: Find products from different categories (complementary items)
            var categoryBasedRecommendations = await GetCategoryBasedRecommendationsAsync(
                cartItemCategoryIds, cartItemProductIds, maxRecommendations - recommendations.Count);
            recommendations.AddRange(categoryBasedRecommendations);

            // Rule 3: If we still need more recommendations, add featured products
            if (recommendations.Count < maxRecommendations)
            {
                var featuredRecommendations = await GetFeaturedRecommendationsAsync(
                    cartItemProductIds, maxRecommendations - recommendations.Count);
                recommendations.AddRange(featuredRecommendations);
            }

            // Remove duplicates and ensure we don't exceed max recommendations
            return recommendations
                .GroupBy(r => r.Id)
                .Select(g => g.First())
                .Take(maxRecommendations)
                .ToList();
        }
        catch (Exception ex)
        {
            // Log the error but return empty list to avoid breaking the UI
            Console.WriteLine($"Error getting product recommendations: {ex.Message}");
            return new List<ProductResponse>();
        }
    }

        private async Task<List<ProductResponse>> GetNameBasedRecommendationsAsync(
            List<string> cartItemProductNames,
            List<int> cartItemProductIds,
            int maxCount)
        {
            if (!cartItemProductNames.Any() || maxCount <= 0)
                return new List<ProductResponse>();

            var recommendations = new List<ProductResponse>();

            foreach (var productName in cartItemProductNames)
            {
                if (recommendations.Count >= maxCount) break;

                // Extract key words from product name (e.g., "Samsung S24 Ultra" -> ["Samsung", "S24", "Ultra"])
                var keyWords = ExtractKeyWords(productName);

                foreach (var keyWord in keyWords)
                {
                    if (recommendations.Count >= maxCount) break;

                    // Find products that contain the key word but are different products
                    var similarProducts = await _context.Products
                        .Include(p => p.Category)
                        .Include(p => p.ProductImages)
                        .Where(p => p.IsActive && 
                                   p.StockQuantity > 0 &&
                                   !cartItemProductIds.Contains(p.Id) &&
                                   (p.Name.Contains(keyWord) || 
                                    p.Brand != null && p.Brand.Contains(keyWord) ||
                                    p.Model != null && p.Model.Contains(keyWord)))
                        .OrderByDescending(p => p.IsFeatured)
                        .ThenByDescending(p => p.StockQuantity)
                        .Take(maxCount - recommendations.Count)
                        .ToListAsync();

                    foreach (var product in similarProducts)
                    {
                        if (recommendations.Count >= maxCount) break;
                        
                        // Check if this product is already in recommendations
                        if (!recommendations.Any(r => r.Id == product.Id))
                        {
                            var productResponse = _mapper.Map<ProductResponse>(product);
                            recommendations.Add(productResponse);
                        }
                    }
                }
            }

            return recommendations;
        }

        private async Task<List<ProductResponse>> GetCategoryBasedRecommendationsAsync(
            List<int> cartItemCategoryIds,
            List<int> cartItemProductIds,
            int maxCount)
        {
            if (!cartItemCategoryIds.Any() || maxCount <= 0)
                return new List<ProductResponse>();

            var recommendations = new List<ProductResponse>();

            // Get cart items to analyze their brands and names for smarter recommendations
            var cartItems = await _context.CartItems
                .Include(ci => ci.Product)
                .Where(ci => cartItemProductIds.Contains(ci.ProductId))
                .ToListAsync();

            // If no cart items found, try getting products directly
            if (!cartItems.Any())
            {
                var products = await _context.Products
                    .Where(p => cartItemProductIds.Contains(p.Id))
                    .ToListAsync();
                
                // Create pseudo cart items for compatibility
                cartItems = products.Select(p => new Database.CartItem 
                { 
                    Product = p, 
                    ProductId = p.Id 
                }).ToList();
            }

            // Extract brands and key product information from cart items
            var cartBrands = cartItems
                .Select(ci => ci.Product.Brand)
                .Where(brand => !string.IsNullOrEmpty(brand))
                .Distinct()
                .ToList();

            var cartProductNames = cartItems
                .Select(ci => ci.Product.Name)
                .ToList();

            // Define complementary category mappings
            var complementaryCategories = GetComplementaryCategories();

            foreach (var categoryId in cartItemCategoryIds)
            {
                if (recommendations.Count >= maxCount) break;

                if (complementaryCategories.TryGetValue(categoryId, out var complementaryCategoryIds))
                {
                    foreach (var complementaryCategoryId in complementaryCategoryIds)
                    {
                        if (recommendations.Count >= maxCount) break;

                        // Get products from complementary categories
                        var complementaryProducts = await _context.Products
                            .Include(p => p.Category)
                            .Include(p => p.ProductImages)
                            .Where(p => p.IsActive &&
                                       p.StockQuantity > 0 &&
                                       p.CategoryId == complementaryCategoryId &&
                                       !cartItemProductIds.Contains(p.Id))
                            .ToListAsync();

                        // Filter products to match brands or product compatibility
                        var compatibleProducts = complementaryProducts
                            .Where(p => IsProductCompatibleWithCart(p, cartBrands, cartProductNames))
                            .OrderByDescending(p => p.IsFeatured)
                            .ThenByDescending(p => p.StockQuantity)
                            .Take(maxCount - recommendations.Count)
                            .ToList();

                        foreach (var product in compatibleProducts)
                        {
                            if (recommendations.Count >= maxCount) break;
                            
                            if (!recommendations.Any(r => r.Id == product.Id))
                            {
                                var productResponse = _mapper.Map<ProductResponse>(product);
                                recommendations.Add(productResponse);
                            }
                        }
                    }
                }
            }

            return recommendations;
        }

        private async Task<List<ProductResponse>> GetFeaturedRecommendationsAsync(
            List<int> cartItemProductIds,
            int maxCount)
        {
            if (maxCount <= 0)
                return new List<ProductResponse>();

            var featuredProducts = await _context.Products
                .Include(p => p.Category)
                .Include(p => p.ProductImages)
                .Where(p => p.IsActive &&
                           p.StockQuantity > 0 &&
                           p.IsFeatured &&
                           !cartItemProductIds.Contains(p.Id))
                .OrderByDescending(p => p.StockQuantity)
                .Take(maxCount)
                .ToListAsync();

            return featuredProducts.Select(p => _mapper.Map<ProductResponse>(p)).ToList();
        }

        private List<string> ExtractKeyWords(string productName)
        {
            if (string.IsNullOrWhiteSpace(productName))
                return new List<string>();

            // Split by common separators and filter out common words
            var commonWords = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
            {
                "the", "a", "an", "and", "or", "but", "in", "on", "at", "to", "for", "of", "with", "by"
            };

            var words = productName.Split(new[] { ' ', '-', '_', '.', ',' }, StringSplitOptions.RemoveEmptyEntries)
                .Where(word => word.Length > 1 && !commonWords.Contains(word.ToLower()))
                .ToList();

            return words;
        }

        private bool IsProductCompatibleWithCart(Database.Product product, List<string> cartBrands, List<string> cartProductNames)
        {
            // If no brands in cart, allow any product (fallback behavior)
            if (!cartBrands.Any())
                return true;

            // Check if product brand matches any cart item brand
            if (!string.IsNullOrEmpty(product.Brand))
            {
                foreach (var cartBrand in cartBrands)
                {
                    if (product.Brand.Contains(cartBrand, StringComparison.OrdinalIgnoreCase) ||
                        cartBrand.Contains(product.Brand, StringComparison.OrdinalIgnoreCase))
                    {
                        return true;
                    }
                }
            }

            // Check if product name contains any brand from cart items
            if (!string.IsNullOrEmpty(product.Name))
            {
                foreach (var cartBrand in cartBrands)
                {
                    if (product.Name.Contains(cartBrand, StringComparison.OrdinalIgnoreCase))
                    {
                        return true;
                    }
                }
            }

            // Check for model compatibility (e.g., "S24" in cart, recommend "S24" accessories)
            foreach (var cartProductName in cartProductNames)
            {
                var cartKeyWords = ExtractKeyWords(cartProductName);
                var productKeyWords = ExtractKeyWords(product.Name);

                // Check if they share significant keywords (models, series, etc.)
                var commonKeywords = cartKeyWords.Intersect(productKeyWords, StringComparer.OrdinalIgnoreCase).ToList();
                
                // If they share at least one meaningful keyword, consider them compatible
                if (commonKeywords.Any())
                {
                    return true;
                }
            }

            // For universal accessories (like generic chargers, screen protectors), check if they mention "universal" or "compatible"
            if (!string.IsNullOrEmpty(product.Name) && 
                (product.Name.Contains("universal", StringComparison.OrdinalIgnoreCase) ||
                 product.Name.Contains("compatible", StringComparison.OrdinalIgnoreCase) ||
                 product.Name.Contains("all phones", StringComparison.OrdinalIgnoreCase)))
            {
                return true;
            }

            return false;
        }

        private Dictionary<int, List<int>> GetComplementaryCategories()
        {
            // Define which categories complement each other
            // This mapping can be expanded based on your business logic
            return new Dictionary<int, List<int>>
            {
                // Smartphones -> Accessories, Cases, Chargers, Audio
                { 1, new List<int> { 4, 5, 6 } },
                
                // Tablets -> Accessories, Cases, Chargers
                { 2, new List<int> { 4, 5, 6 } },
                
                // Laptops -> Accessories, Chargers
                { 3, new List<int> { 4, 6 } },
                
                // Accessories -> Smartphones, Tablets (for cross-selling)
                { 4, new List<int> { 1, 2 } },
                
                // Phone Cases -> Smartphones, Tablets
                { 5, new List<int> { 1, 2 } },
                
                // Chargers -> Smartphones, Tablets, Laptops
                { 6, new List<int> { 1, 2, 3 } }
            };
        }
    }
}
