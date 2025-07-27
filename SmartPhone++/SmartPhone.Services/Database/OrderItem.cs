using System;
using System.ComponentModel.DataAnnotations;

namespace SmartPhone.Services.Database
{
    public class OrderItem
    {
        [Key]
        public int Id { get; set; }
        
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
        public string CurrencyCode { get; set; } = string.Empty; // USD, EUR, BAM, etc.
        
        [Required]
        [MaxLength(5)]
        public string CurrencySymbol { get; set; } = string.Empty; // $, €, KM
        
        [MaxLength(200)]
        public string? ProductName { get; set; } // Snapshot of product name at time of order
        
        [MaxLength(100)]
        public string? ProductSKU { get; set; } // Snapshot of product SKU at time of order
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        // Foreign keys
        public int OrderId { get; set; }
        public int ProductId { get; set; }
        
        // Navigation properties
        public Order Order { get; set; } = null!;
        public Product Product { get; set; } = null!;
    }
} 