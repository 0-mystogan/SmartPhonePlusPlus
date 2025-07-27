using Microsoft.EntityFrameworkCore;
using SmartPhone.Services.Database;
using SmartPhone.Services.Interfaces;
using SmartPhone.Model.Responses;
using SmartPhone.Model.Requests;
using SmartPhone.Model.SearchObjects;
using MapsterMapper;

namespace SmartPhone.Services.Services
{
    public class ProductService : BaseCRUDService<ProductResponse, ProductSearchObject, Product, ProductUpsertRequest, ProductUpsertRequest>, IProductService
    {
        public ProductService(SmartPhoneDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public async Task<IEnumerable<ProductResponse>> GetActiveProductsAsync()
        {
            var products = await _context.Products
                .Where(p => p.IsActive)
                .Include(p => p.Category)
                .Include(p => p.ProductPrices.Where(pp => pp.IsActive))
                    .ThenInclude(pp => pp.Currency)
                .Include(p => p.Reviews.Where(r => r.IsApproved))
                .OrderBy(p => p.Name)
                .ToListAsync();
            
            return products.Select(MapToResponse).ToList();
        }

        public async Task<IEnumerable<ProductResponse>> GetFeaturedProductsAsync()
        {
            var products = await _context.Products
                .Where(p => p.IsActive && p.IsFeatured)
                .Include(p => p.Category)
                .Include(p => p.ProductPrices.Where(pp => pp.IsActive))
                    .ThenInclude(pp => pp.Currency)
                .Include(p => p.Reviews.Where(r => r.IsApproved))
                .OrderBy(p => p.Name)
                .ToListAsync();
            
            return products.Select(MapToResponse).ToList();
        }

        public async Task<IEnumerable<ProductResponse>> GetProductsByCategoryAsync(int categoryId)
        {
            var products = await _context.Products
                .Where(p => p.CategoryId == categoryId && p.IsActive)
                .Include(p => p.Category)
                .Include(p => p.ProductPrices.Where(pp => pp.IsActive))
                    .ThenInclude(pp => pp.Currency)
                .Include(p => p.Reviews.Where(r => r.IsApproved))
                .OrderBy(p => p.Name)
                .ToListAsync();
            
            return products.Select(MapToResponse).ToList();
        }

        public async Task<IEnumerable<ProductResponse>> GetLowStockProductsAsync()
        {
            var products = await _context.Products
                .Where(p => p.IsActive && p.MinimumStockLevel.HasValue && p.StockQuantity <= p.MinimumStockLevel.Value)
                .Include(p => p.Category)
                .OrderBy(p => p.StockQuantity)
                .ToListAsync();
            
            return products.Select(MapToResponse).ToList();
        }

        public async Task<bool> UpdateStockQuantityAsync(int productId, int quantity)
        {
            var product = await _context.Products.FindAsync(productId);
            if (product == null) return false;

            product.StockQuantity = quantity;
            product.UpdatedAt = DateTime.UtcNow;
            
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> CheckProductAvailabilityAsync(int productId, int requiredQuantity)
        {
            var product = await _context.Products.FindAsync(productId);
            return product != null && product.IsActive && product.StockQuantity >= requiredQuantity;
        }

        public async Task<IEnumerable<ProductResponse>> GetProductsByBrandAsync(string brand)
        {
            var products = await _context.Products
                .Where(p => p.Brand == brand && p.IsActive)
                .Include(p => p.Category)
                .Include(p => p.ProductPrices.Where(pp => pp.IsActive))
                    .ThenInclude(pp => pp.Currency)
                .Include(p => p.Reviews.Where(r => r.IsApproved))
                .OrderBy(p => p.Name)
                .ToListAsync();
            
            return products.Select(MapToResponse).ToList();
        }

        public async Task<decimal?> GetProductPriceAsync(int productId, int currencyId)
        {
            var productPrice = await _context.ProductPrices
                .Where(pp => pp.ProductId == productId && pp.CurrencyId == currencyId && pp.IsActive)
                .OrderByDescending(pp => pp.CreatedAt)
                .FirstOrDefaultAsync();

            return productPrice?.DiscountedPrice ?? productPrice?.Price;
        }

        protected override ProductResponse MapToResponse(Product entity)
        {
            var response = _mapper.Map<ProductResponse>(entity);
            response.CategoryName = entity.Category?.Name ?? string.Empty;
            
            // Get current price
            var currentPrice = entity.ProductPrices
                .Where(pp => pp.IsActive)
                .OrderByDescending(pp => pp.CreatedAt)
                .FirstOrDefault();
            
            response.CurrentPrice = currentPrice?.DiscountedPrice ?? currentPrice?.Price;
            response.OriginalPrice = currentPrice?.Price;
            
            // Calculate average rating
            if (entity.Reviews.Any())
            {
                response.AverageRating = entity.Reviews.Average(r => r.Rating);
                response.ReviewCount = entity.Reviews.Count;
            }
            
            return response;
        }

        protected override IQueryable<Product> ApplyFilter(IQueryable<Product> query, ProductSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
                query = query.Where(p => p.Name.Contains(search.Name));
            
            if (!string.IsNullOrEmpty(search.Brand))
                query = query.Where(p => p.Brand == search.Brand);
            
            if (!string.IsNullOrEmpty(search.SKU))
                query = query.Where(p => p.SKU == search.SKU);
            
            if (search.CategoryId.HasValue)
                query = query.Where(p => p.CategoryId == search.CategoryId.Value);
            
            if (search.IsActive.HasValue)
                query = query.Where(p => p.IsActive == search.IsActive.Value);
            
            if (search.IsFeatured.HasValue)
                query = query.Where(p => p.IsFeatured == search.IsFeatured.Value);
            
            if (search.InStock.HasValue && search.InStock.Value)
                query = query.Where(p => p.StockQuantity > 0);
            
            return query;
        }
    }
} 