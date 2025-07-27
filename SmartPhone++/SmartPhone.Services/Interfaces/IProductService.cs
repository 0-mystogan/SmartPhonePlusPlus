using SmartPhone.Model.Responses;
using SmartPhone.Model.Requests;
using SmartPhone.Model.SearchObjects;

namespace SmartPhone.Services.Interfaces
{
    public interface IProductService : ICRUDService<ProductResponse, ProductSearchObject, ProductUpsertRequest, ProductUpsertRequest>
    {
        Task<IEnumerable<ProductResponse>> GetActiveProductsAsync();
        Task<IEnumerable<ProductResponse>> GetFeaturedProductsAsync();
        Task<IEnumerable<ProductResponse>> GetProductsByCategoryAsync(int categoryId);
        Task<IEnumerable<ProductResponse>> GetLowStockProductsAsync();
        Task<bool> UpdateStockQuantityAsync(int productId, int quantity);
        Task<bool> CheckProductAvailabilityAsync(int productId, int requiredQuantity);
        Task<IEnumerable<ProductResponse>> GetProductsByBrandAsync(string brand);
        Task<decimal?> GetProductPriceAsync(int productId, int currencyId);
    }
} 