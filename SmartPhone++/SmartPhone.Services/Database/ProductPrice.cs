using System;
using System.ComponentModel.DataAnnotations;

namespace SmartPhone.Services.Database
{
    public class ProductPrice
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        [Range(0, double.MaxValue)]
        public decimal Price { get; set; }
        
        [Range(0, double.MaxValue)]
        public decimal? DiscountedPrice { get; set; }
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        public DateTime? UpdatedAt { get; set; }
        
        public DateTime? ValidFrom { get; set; }
        
        public DateTime? ValidTo { get; set; }
        
        public bool IsActive { get; set; } = true;
        
        // Foreign keys
        public int ProductId { get; set; }
        public int CurrencyId { get; set; }
        
        // Navigation properties
        public Product Product { get; set; } = null!;
        public Currency Currency { get; set; } = null!;
    }
} 