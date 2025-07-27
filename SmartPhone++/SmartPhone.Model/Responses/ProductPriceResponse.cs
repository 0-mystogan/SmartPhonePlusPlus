using System;

namespace SmartPhone.Model.Responses
{
    public class ProductPriceResponse
    {
        public int Id { get; set; }
        public decimal Price { get; set; }
        public decimal? DiscountedPrice { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public DateTime? ValidFrom { get; set; }
        public DateTime? ValidTo { get; set; }
        public bool IsActive { get; set; }
        public int ProductId { get; set; }
        public int CurrencyId { get; set; }
        public string ProductName { get; set; } = string.Empty;
        public string CurrencyCode { get; set; } = string.Empty;
        public string CurrencySymbol { get; set; } = string.Empty;
    }
} 