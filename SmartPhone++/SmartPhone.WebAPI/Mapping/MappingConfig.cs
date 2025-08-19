using Mapster;
using SmartPhone.Model.Responses;
using SmartPhone.Model.Requests;
using SmartPhone.Services.Database;
using System;
using System.Linq;

namespace SmartPhone.WebAPI.Mapping
{
    /// <summary>
    /// Centralized mapping configuration for Mapster
    /// </summary>
    public static class MappingConfig
    {
        /// <summary>
        /// Configures all Mapster mappings for the application
        /// </summary>
        public static void ConfigureMappings()
        {
            ConfigureCategoryMappings();
            ConfigureProductMappings();
            ConfigureProductImageMappings();
            ConfigurePartMappings();
            ConfigureServiceMappings();
            ConfigureCartMappings();
            ConfigureCartItemMappings();
        }

        private static void ConfigureCategoryMappings()
        {
            TypeAdapterConfig<Category, CategoryResponse>
                .NewConfig()
                .Map(dest => dest.ParentCategoryName, src => src.ParentCategory != null ? src.ParentCategory.Name : null);

            TypeAdapterConfig<CategoryUpsertRequest, Category>
                .NewConfig()
                .Map(dest => dest.CreatedAt, src => DateTime.UtcNow);
        }

        private static void ConfigureProductMappings()
        {
            TypeAdapterConfig<Product, ProductResponse>
                .NewConfig()
                .Map(dest => dest.CategoryName, src => src.Category != null ? src.Category.Name : string.Empty)
                .Map(dest => dest.CurrentPrice, src => src.DiscountedPrice ?? src.Price)
                .Map(dest => dest.OriginalPrice, src => src.Price);

            TypeAdapterConfig<ProductUpsertRequest, Product>
                .NewConfig()
                .Map(dest => dest.CreatedAt, src => DateTime.UtcNow);


        }

        private static void ConfigureProductImageMappings()
        {
            TypeAdapterConfig<ProductImage, ProductImageResponse>
                .NewConfig()
                .Map(dest => dest.ProductName, src => src.Product != null ? src.Product.Name : string.Empty);

            TypeAdapterConfig<ProductImageUpsertRequest, ProductImage>
                .NewConfig()
                .Map(dest => dest.CreatedAt, src => DateTime.UtcNow);
        }

        private static void ConfigurePartMappings()
        {
            TypeAdapterConfig<Part, PartResponse>
                .NewConfig()
                .Map(dest => dest.PartCategoryName, src => src.PartCategory != null ? src.PartCategory.Name : "Uncategorized");

            TypeAdapterConfig<PartUpsertRequest, Part>
                .NewConfig()
                .Map(dest => dest.CreatedAt, src => DateTime.UtcNow);
        }

        private static void ConfigureServiceMappings()
        {
            TypeAdapterConfig<Service, ServiceResponse>
                .NewConfig()
                .Map(dest => dest.ServiceFee, src => (double)src.ServiceFee);

            TypeAdapterConfig<ServiceUpsertRequest, Service>
                .NewConfig()
                .Map(dest => dest.CreatedAt, src => DateTime.UtcNow);
        }

        private static void ConfigureCartMappings()
        {
            TypeAdapterConfig<Cart, CartResponse>
                .NewConfig()
                .Map(dest => dest.UserName, src => src.User != null ? src.User.Username : string.Empty)
                .Map(dest => dest.UserEmail, src => src.User != null ? src.User.Email : string.Empty)
                .Map(dest => dest.TotalItems, src => src.CartItems != null ? src.CartItems.Count : 0)
                .Map(dest => dest.CartItems, src => src.CartItems);

            TypeAdapterConfig<CartUpsertRequest, Cart>
                .NewConfig()
                .Map(dest => dest.CreatedAt, src => DateTime.UtcNow);
        }

        private static void ConfigureCartItemMappings()
        {
            TypeAdapterConfig<CartItem, CartItemResponse>
                .NewConfig()
                .Map(dest => dest.ProductName, src => src.Product != null ? src.Product.Name : string.Empty)
                .Map(dest => dest.ProductPrice, src => src.Product != null ? src.Product.Price : 0)
                .Map(dest => dest.TotalPrice, src => src.Product != null ? src.Product.Price * src.Quantity : 0)
                .Map(dest => dest.ProductImageUrl, src => src.Product != null && src.Product.ProductImages != null && src.Product.ProductImages.Any() 
                    ? Convert.ToBase64String(src.Product.ProductImages.First().ImageData ?? new byte[0])
                    : null)
                .Map(dest => dest.ProductCategoryId, src => src.Product != null ? src.Product.CategoryId : 0)
                .Map(dest => dest.ProductCategoryName, src => src.Product != null && src.Product.Category != null ? src.Product.Category.Name : string.Empty);

            TypeAdapterConfig<CartItemUpsertRequest, CartItem>
                .NewConfig()
                .Map(dest => dest.CreatedAt, src => DateTime.UtcNow)
                .Map(dest => dest.CartId, src => src.CartId);
        }
    }
} 