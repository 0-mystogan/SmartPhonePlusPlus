using Microsoft.EntityFrameworkCore;
using SmartPhone.Services.Database;
using SmartPhone.Services.Interfaces;
using SmartPhone.Model.Responses;
using SmartPhone.Model.Requests;
using SmartPhone.Model.SearchObjects;
using MapsterMapper;
using System.Linq;

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
                .Include(p => p.ProductImages.OrderBy(pi => pi.DisplayOrder))
                .OrderBy(p => p.Name)
                .ToListAsync();
            
            return products.Select(MapToResponse).ToList();
        }

        public async Task<IEnumerable<ProductResponse>> GetFeaturedProductsAsync()
        {
            var products = await _context.Products
                .Where(p => p.IsActive && p.IsFeatured)
                .Include(p => p.Category)
                .Include(p => p.ProductImages.OrderBy(pi => pi.DisplayOrder))
                .OrderBy(p => p.Name)
                .ToListAsync();
            
            return products.Select(MapToResponse).ToList();
        }

        public async Task<IEnumerable<ProductResponse>> GetProductsByCategoryAsync(int categoryId)
        {
            var products = await _context.Products
                .Where(p => p.CategoryId == categoryId && p.IsActive)
                .Include(p => p.Category)
                .Include(p => p.ProductImages.OrderBy(pi => pi.DisplayOrder))
                .OrderBy(p => p.Name)
                .ToListAsync();
            
            return products.Select(MapToResponse).ToList();
        }

        public async Task<IEnumerable<ProductResponse>> GetLowStockProductsAsync()
        {
            var products = await _context.Products
                .Where(p => p.IsActive && p.MinimumStockLevel.HasValue && p.StockQuantity <= p.MinimumStockLevel.Value)
                .Include(p => p.Category)
                .Include(p => p.ProductImages.OrderBy(pi => pi.DisplayOrder))
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
                .Include(p => p.ProductImages.OrderBy(pi => pi.DisplayOrder))
                .OrderBy(p => p.Name)
                .ToListAsync();
            
            return products.Select(MapToResponse).ToList();
        }

        protected override ProductResponse MapToResponse(Product entity)
        {
            var response = _mapper.Map<ProductResponse>(entity);
            response.CategoryName = entity.Category?.Name ?? string.Empty;
            
            // Set current price from the entity
            response.CurrentPrice = entity.DiscountedPrice ?? entity.Price;
            response.OriginalPrice = entity.Price;
            
            // Map product images
            response.ProductImages = entity.ProductImages
                .OrderBy(pi => pi.DisplayOrder)
                .Select(pi => new ProductImageResponse
                {
                    Id = pi.Id,
                    ImageUrl = pi.ImageUrl,
                    AltText = pi.AltText,
                    IsPrimary = pi.IsPrimary,
                    DisplayOrder = pi.DisplayOrder,
                    CreatedAt = pi.CreatedAt,
                    ProductId = pi.ProductId,
                    ProductName = entity.Name
                })
                .ToList();
            
            return response;
        }

        protected override IQueryable<Product> ApplyFilter(IQueryable<Product> query, ProductSearchObject search)
        {
            // Full Text Search (FTS) - search in name and description
            if (!string.IsNullOrEmpty(search.FTS))
            {
                var searchTerm = search.FTS.ToLower();
                query = query.Where(p => 
                    p.Name.ToLower().Contains(searchTerm) || 
                    (p.Description != null && p.Description.ToLower().Contains(searchTerm))
                );
            }
            
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
            
            // Price range filtering
            if (search.MinPrice.HasValue)
                query = query.Where(p => p.Price >= search.MinPrice.Value);
            
            if (search.MaxPrice.HasValue)
                query = query.Where(p => p.Price <= search.MaxPrice.Value);
            
            return query;
        }

        public override async Task<PagedResult<ProductResponse>> GetAsync(ProductSearchObject search)
        {
            var query = _context.Products
                .Include(p => p.Category)
                .Include(p => p.ProductImages.OrderBy(pi => pi.DisplayOrder))
                .AsQueryable();
            
            query = ApplyFilter(query, search);

            int? totalCount = null;
            if (search.IncludeTotalCount)
            {
                totalCount = await query.CountAsync();
            }

            if (!search.RetrieveAll)
            {
                if (search.Page.HasValue)
                {
                    query = query.Skip(search.Page.Value * search.PageSize.Value);
                }
                if (search.PageSize.HasValue)
                {
                    query = query.Take(search.PageSize.Value);
                }
            }

            var list = await query.ToListAsync();
            return new PagedResult<ProductResponse>
            {
                Items = list.Select(MapToResponse).ToList(),
                TotalCount = totalCount
            };
        }

        public override async Task<ProductResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Products
                .Include(p => p.Category)
                .Include(p => p.ProductImages.OrderBy(pi => pi.DisplayOrder))
                .FirstOrDefaultAsync(p => p.Id == id);
            
            if (entity == null)
                return null;

            return MapToResponse(entity);
        }

        public override async Task<ProductResponse> CreateAsync(ProductUpsertRequest request)
        {
            var entity = new Product();
            MapInsertToEntity(entity, request);
            _context.Products.Add(entity);

            await BeforeInsert(entity, request);

            await _context.SaveChangesAsync();

            // Create product images if provided
            if (request.ProductImages != null && request.ProductImages.Any())
            {
                foreach (var imageRequest in request.ProductImages)
                {
                    var productImage = new ProductImage
                    {
                        ImageUrl = imageRequest.ImageUrl,
                        AltText = imageRequest.AltText,
                        IsPrimary = imageRequest.IsPrimary,
                        DisplayOrder = imageRequest.DisplayOrder,
                        ProductId = entity.Id,
                        CreatedAt = DateTime.UtcNow
                    };
                    
                    _context.ProductImages.Add(productImage);
                }
                
                await _context.SaveChangesAsync();
            }

            return await GetByIdAsync(entity.Id);
        }

        public override async Task<ProductResponse?> UpdateAsync(int id, ProductUpsertRequest request)
        {
            var entity = await _context.Products
                .Include(p => p.ProductImages)
                .FirstOrDefaultAsync(p => p.Id == id);
                
            if (entity == null)
                return null;

            await BeforeUpdate(entity, request);

            MapUpdateToEntity(entity, request);

            // Handle product images update
            if (request.ProductImages != null && request.ProductImages.Any())
            {
                // Remove existing images
                _context.ProductImages.RemoveRange(entity.ProductImages);
                
                // Add new images
                foreach (var imageRequest in request.ProductImages)
                {
                    var productImage = new ProductImage
                    {
                        ImageUrl = imageRequest.ImageUrl,
                        AltText = imageRequest.AltText,
                        IsPrimary = imageRequest.IsPrimary,
                        DisplayOrder = imageRequest.DisplayOrder,
                        ProductId = entity.Id,
                        CreatedAt = DateTime.UtcNow
                    };
                    
                    _context.ProductImages.Add(productImage);
                }
            }

            await _context.SaveChangesAsync();
            return await GetByIdAsync(entity.Id);
        }
    }
} 