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

            public async Task<List<ProductResponse>> GetRecommendationsForUserAsync(int userId, int maxRecommendations = 10)
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
        int maxRecommendations = 10)
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

                        var complementaryProducts = await _context.Products
                            .Include(p => p.Category)
                            .Include(p => p.ProductImages)
                            .Where(p => p.IsActive &&
                                       p.StockQuantity > 0 &&
                                       p.CategoryId == complementaryCategoryId &&
                                       !cartItemProductIds.Contains(p.Id))
                            .OrderByDescending(p => p.IsFeatured)
                            .ThenByDescending(p => p.StockQuantity)
                            .Take(maxCount - recommendations.Count)
                            .ToListAsync();

                        foreach (var product in complementaryProducts)
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
