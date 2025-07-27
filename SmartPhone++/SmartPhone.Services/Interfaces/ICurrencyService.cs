using SmartPhone.Services.Database;

namespace SmartPhone.Services.Interfaces
{
    public interface ICurrencyService
    {
        Task<Currency?> GetDefaultCurrencyAsync();
        Task<Currency?> GetCurrencyByCodeAsync(string currencyCode);
        Task<IEnumerable<Currency>> GetActiveCurrenciesAsync();
        Task<decimal?> GetProductPriceAsync(int productId, string currencyCode);
        Task<ProductPrice?> GetProductPriceEntityAsync(int productId, string currencyCode);
        Task<IEnumerable<ProductPrice>> GetProductPricesAsync(int productId);
        Task<bool> SetProductPriceAsync(int productId, string currencyCode, decimal price, decimal? discountedPrice = null);
        Task<bool> UpdateProductPriceAsync(int productId, string currencyCode, decimal price, decimal? discountedPrice = null);
        Task<bool> DeleteProductPriceAsync(int productId, string currencyCode);
    }
} 