using System;

namespace SmartPhone.Model.Responses
{
    public class OrderItemResponse
    {
        public int Id { get; set; }
        public int Quantity { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal? DiscountAmount { get; set; }
        public decimal TotalPrice { get; set; }
        public string CurrencyCode { get; set; } = string.Empty;
        public string CurrencySymbol { get; set; } = string.Empty;
        public string? ProductName { get; set; }
        public string? ProductSKU { get; set; }
        public DateTime CreatedAt { get; set; }
        public int OrderId { get; set; }
        public int ProductId { get; set; }
        public string OrderNumber { get; set; } = string.Empty;
        public string ProductCurrentName { get; set; } = string.Empty;
    }
} 