using System.ComponentModel.DataAnnotations;

namespace SmartPhone.Model.Requests
{
    public class OrderItemUpsertRequest
    {
        [Required]
        [Range(1, int.MaxValue)]
        public int Quantity { get; set; }
        
        [Required]
        [Range(0, double.MaxValue)]
        public decimal UnitPrice { get; set; }
        
        [Range(0, double.MaxValue)]
        public decimal? DiscountAmount { get; set; }
        
        [Required]
        [Range(0, double.MaxValue)]
        public decimal TotalPrice { get; set; }
        
        [Required]
        [MaxLength(3)]
        public string CurrencyCode { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(5)]
        public string CurrencySymbol { get; set; } = string.Empty;
        
        [MaxLength(200)]
        public string? ProductName { get; set; }
        
        [MaxLength(100)]
        public string? ProductSKU { get; set; }
        
        [Required]
        public int OrderId { get; set; }
        
        [Required]
        public int ProductId { get; set; }
    }
} 