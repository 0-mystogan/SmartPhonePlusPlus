using Microsoft.EntityFrameworkCore;
using SmartPhone.Services.Database;
using SmartPhone.Services.Interfaces;

namespace SmartPhone.Services.Services
{
    public class CurrencyService : ICurrencyService
    {
        private readonly SmartPhoneDbContext _context;

        public CurrencyService(SmartPhoneDbContext context)
        {
            _context = context;
        }

        public async Task<Currency?> GetDefaultCurrencyAsync()
        {
            return await _context.Currencies
                .FirstOrDefaultAsync(c => c.IsDefault && c.IsActive);
        }

        public async Task<Currency?> GetCurrencyByCodeAsync(string currencyCode)
        {
            return await _context.Currencies
                .FirstOrDefaultAsync(c => c.Code == currencyCode && c.IsActive);
        }

        public async Task<IEnumerable<Currency>> GetActiveCurrenciesAsync()
        {
            return await _context.Currencies
                .Where(c => c.IsActive)
                .OrderBy(c => c.IsDefault)
                .ThenBy(c => c.Code)
                .ToListAsync();
        }

        public async Task<decimal?> GetProductPriceAsync(int productId, string currencyCode)
        {
            var productPrice = await _context.ProductPrices
                .Include(pp => pp.Currency)
                .FirstOrDefaultAsync(pp => pp.ProductId == productId && 
                                         pp.Currency.Code == currencyCode && 
                                         pp.IsActive);

            return productPrice?.Price;
        }

        public async Task<ProductPrice?> GetProductPriceEntityAsync(int productId, string currencyCode)
        {
            return await _context.ProductPrices
                .Include(pp => pp.Currency)
                .FirstOrDefaultAsync(pp => pp.ProductId == productId && 
                                         pp.Currency.Code == currencyCode && 
                                         pp.IsActive);
        }

        public async Task<IEnumerable<ProductPrice>> GetProductPricesAsync(int productId)
        {
            return await _context.ProductPrices
                .Include(pp => pp.Currency)
                .Where(pp => pp.ProductId == productId && pp.IsActive)
                .OrderBy(pp => pp.Currency.IsDefault)
                .ThenBy(pp => pp.Currency.Code)
                .ToListAsync();
        }

        public async Task<bool> SetProductPriceAsync(int productId, string currencyCode, decimal price, decimal? discountedPrice = null)
        {
            var currency = await GetCurrencyByCodeAsync(currencyCode);
            if (currency == null)
                return false;

            var existingPrice = await GetProductPriceEntityAsync(productId, currencyCode);
            if (existingPrice != null)
                return false; // Price already exists, use UpdateProductPriceAsync instead

            var productPrice = new ProductPrice
            {
                ProductId = productId,
                CurrencyId = currency.Id,
                Price = price,
                DiscountedPrice = discountedPrice,
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            };

            _context.ProductPrices.Add(productPrice);
            var result = await _context.SaveChangesAsync();
            return result > 0;
        }

        public async Task<bool> UpdateProductPriceAsync(int productId, string currencyCode, decimal price, decimal? discountedPrice = null)
        {
            var existingPrice = await GetProductPriceEntityAsync(productId, currencyCode);
            if (existingPrice == null)
                return false;

            existingPrice.Price = price;
            existingPrice.DiscountedPrice = discountedPrice;
            existingPrice.UpdatedAt = DateTime.UtcNow;

            var result = await _context.SaveChangesAsync();
            return result > 0;
        }

        public async Task<bool> DeleteProductPriceAsync(int productId, string currencyCode)
        {
            var existingPrice = await GetProductPriceEntityAsync(productId, currencyCode);
            if (existingPrice == null)
                return false;

            existingPrice.IsActive = false;
            existingPrice.UpdatedAt = DateTime.UtcNow;

            var result = await _context.SaveChangesAsync();
            return result > 0;
        }
    }
} 