using System;

namespace SmartPhone.Model.Responses
{
    public class WishlistItemResponse
    {
        public int Id { get; set; }
        public DateTime CreatedAt { get; set; }
        public int WishlistId { get; set; }
        public int ProductId { get; set; }
        public string ProductName { get; set; } = string.Empty;
        public string? ProductSKU { get; set; }
        public decimal? ProductPrice { get; set; }
        public string? ProductImageUrl { get; set; }
        public bool ProductIsActive { get; set; }
    }
} 