using Microsoft.EntityFrameworkCore;
using SmartPhone.Services.Database;
using SmartPhone.Services.Interfaces;
using SmartPhone.Model.Responses;
using SmartPhone.Model.Requests;
using SmartPhone.Model.SearchObjects;
using MapsterMapper;
using System;
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
                    ImageData = pi.ImageData,
                    FileName = pi.FileName,
                    ContentType = pi.ContentType,
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
            // Validate required fields for creation
            if (string.IsNullOrEmpty(request.Name))
                throw new ArgumentException("Name is required for product creation");
            if (!request.Price.HasValue || request.Price.Value <= 0)
                throw new ArgumentException("Price is required and must be greater than 0 for product creation");
            if (!request.StockQuantity.HasValue || request.StockQuantity.Value < 0)
                throw new ArgumentException("StockQuantity is required and must be non-negative for product creation");
            if (!request.CategoryId.HasValue || request.CategoryId.Value <= 0)
                throw new ArgumentException("CategoryId is required for product creation");

            var entity = new Product();
            MapInsertToEntity(entity, request);
            _context.Products.Add(entity);

            await BeforeInsert(entity, request);

            await _context.SaveChangesAsync();

            // Create product images if provided (simple approach)
            if (request.Images != null && request.Images.Any())
            {
                for (int i = 0; i < request.Images.Count; i++)
                {
                    var base64Image = request.Images[i];
                    if (!string.IsNullOrEmpty(base64Image))
                    {
                        try
                        {
                            byte[] imageData = Convert.FromBase64String(base64Image);
                            Console.WriteLine($"Processing simple image {i + 1}: {imageData.Length} bytes");
                            
                            var productImage = new ProductImage
                            {
                                ImageData = imageData,
                                FileName = $"product_image_{i + 1}.jpg",
                                ContentType = "image/jpeg",
                                AltText = $"Product image {i + 1}",
                                IsPrimary = i == 0, // First image is primary
                                DisplayOrder = i + 1,
                                ProductId = entity.Id,
                                CreatedAt = DateTime.UtcNow
                            };
                            
                            _context.ProductImages.Add(productImage);
                        }
                        catch (FormatException ex)
                        {
                            Console.WriteLine($"Error converting base64 string to bytes: {ex.Message}");
                            continue; // Skip this image if conversion fails
                        }
                    }
                }
                
                await _context.SaveChangesAsync();
            }
            
            // Handle complex ProductImages approach for backward compatibility
            if (request.ProductImages != null && request.ProductImages.Any())
            {
                foreach (var imageRequest in request.ProductImages)
                {
                    // Handle base64 string conversion if ImageData is empty but ImageDataString is provided
                    byte[] imageData = imageRequest.ImageData;
                    Console.WriteLine($"Processing complex image in CreateAsync: {imageRequest.FileName}");
                    Console.WriteLine($"ImageData length: {imageData.Length}");
                    Console.WriteLine($"ImageDataString provided: {!string.IsNullOrEmpty(imageRequest.ImageDataString)}");
                    
                    if (imageData.Length == 0 && !string.IsNullOrEmpty(imageRequest.ImageDataString))
                    {
                        try
                        {
                            imageData = Convert.FromBase64String(imageRequest.ImageDataString);
                            Console.WriteLine($"Successfully converted base64 to bytes. Length: {imageData.Length}");
                        }
                        catch (FormatException ex)
                        {
                            Console.WriteLine($"Error converting base64 string to bytes: {ex.Message}");
                            continue; // Skip this image if conversion fails
                        }
                    }
                    
                    var productImage = new ProductImage
                    {
                        ImageData = imageData,
                        FileName = imageRequest.FileName,
                        ContentType = imageRequest.ContentType,
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
            try
            {
                var entity = await _context.Products
                    .Include(p => p.ProductImages)
                    .FirstOrDefaultAsync(p => p.Id == id);
                    
                if (entity == null)
                    return null;

            await BeforeUpdate(entity, request);

            // Handle partial updates - only update fields that are provided
            if (!string.IsNullOrEmpty(request.Name))
                entity.Name = request.Name;
            if (request.Description != null)
                entity.Description = request.Description;
            if (request.Price.HasValue && request.Price.Value > 0)
                entity.Price = request.Price.Value;
            if (request.DiscountedPrice.HasValue)
                entity.DiscountedPrice = request.DiscountedPrice.Value;
            if (request.StockQuantity.HasValue && request.StockQuantity.Value >= 0)
                entity.StockQuantity = request.StockQuantity.Value;
            if (request.MinimumStockLevel.HasValue)
                entity.MinimumStockLevel = request.MinimumStockLevel.Value;
            if (!string.IsNullOrEmpty(request.SKU))
                entity.SKU = request.SKU;
            if (!string.IsNullOrEmpty(request.Brand))
                entity.Brand = request.Brand;
            if (!string.IsNullOrEmpty(request.Model))
                entity.Model = request.Model;
            if (!string.IsNullOrEmpty(request.Color))
                entity.Color = request.Color;
            if (!string.IsNullOrEmpty(request.Size))
                entity.Size = request.Size;
            if (!string.IsNullOrEmpty(request.Weight))
                entity.Weight = request.Weight;
            if (!string.IsNullOrEmpty(request.Dimensions))
                entity.Dimensions = request.Dimensions;
            if (request.CategoryId.HasValue && request.CategoryId.Value > 0)
                entity.CategoryId = request.CategoryId.Value;
            
            // Update boolean fields
            entity.IsActive = request.IsActive;
            entity.IsFeatured = request.IsFeatured;
            
            // Set UpdatedAt timestamp
            entity.UpdatedAt = DateTime.UtcNow;

            // Handle product images update (simple approach)
            if (request.Images != null && request.Images.Any())
            {
                // Remove existing images
                _context.ProductImages.RemoveRange(entity.ProductImages);
                
                // Add new images
                for (int i = 0; i < request.Images.Count; i++)
                {
                    var base64Image = request.Images[i];
                    if (!string.IsNullOrEmpty(base64Image))
                    {
                        try
                        {
                            byte[] imageData = Convert.FromBase64String(base64Image);
                            Console.WriteLine($"Processing simple image {i + 1} in UpdateAsync: {imageData.Length} bytes");
                            
                            var productImage = new ProductImage
                            {
                                ImageData = imageData,
                                FileName = $"product_image_{i + 1}.jpg",
                                ContentType = "image/jpeg",
                                AltText = $"Product image {i + 1}",
                                IsPrimary = i == 0, // First image is primary
                                DisplayOrder = i + 1,
                                ProductId = entity.Id,
                                CreatedAt = DateTime.UtcNow
                            };
                            
                            _context.ProductImages.Add(productImage);
                        }
                        catch (FormatException ex)
                        {
                            Console.WriteLine($"Error converting base64 string to bytes: {ex.Message}");
                            continue; // Skip this image if conversion fails
                        }
                    }
                }
            }
            
            // Handle complex ProductImages approach for backward compatibility
            if (request.ProductImages != null && request.ProductImages.Any())
            {
                // Remove existing images (if not already removed by simple approach)
                if (request.Images == null || !request.Images.Any())
                {
                    _context.ProductImages.RemoveRange(entity.ProductImages);
                }
                
                // Add new images
                foreach (var imageRequest in request.ProductImages)
                {
                    // Handle base64 string conversion if ImageData is empty but ImageDataString is provided
                    byte[] imageData = imageRequest.ImageData;
                    Console.WriteLine($"Processing complex image in UpdateAsync: {imageRequest.FileName}");
                    Console.WriteLine($"ImageData length: {imageData.Length}");
                    Console.WriteLine($"ImageDataString provided: {!string.IsNullOrEmpty(imageRequest.ImageDataString)}");
                    
                    if (imageData.Length == 0 && !string.IsNullOrEmpty(imageRequest.ImageDataString))
                    {
                        try
                        {
                            imageData = Convert.FromBase64String(imageRequest.ImageDataString);
                            Console.WriteLine($"Successfully converted base64 to bytes. Length: {imageData.Length}");
                        }
                        catch (FormatException ex)
                        {
                            Console.WriteLine($"Error converting base64 string to bytes: {ex.Message}");
                            continue; // Skip this image if conversion fails
                        }
                    }
                    
                    var productImage = new ProductImage
                    {
                        ImageData = imageData,
                        FileName = imageRequest.FileName,
                        ContentType = imageRequest.ContentType,
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
            catch (Exception ex)
            {
                // Log the exception for debugging
                Console.WriteLine($"Error in ProductService.UpdateAsync: {ex.Message}");
                Console.WriteLine($"StackTrace: {ex.StackTrace}");
                throw;
            }
        }

        protected override void MapUpdateToEntity(Product entity, ProductUpsertRequest request)
        {
            // Don't use Mapster for updates - we handle it manually in UpdateAsync
            // This prevents Mapster from trying to map null values to required fields
        }
    }
} 