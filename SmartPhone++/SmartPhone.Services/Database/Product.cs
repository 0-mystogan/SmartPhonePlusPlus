using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace SmartPhone.Services.Database
{
    public class Product
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        [MaxLength(200)]
        public string Name { get; set; } = string.Empty;
        
        [MaxLength(1000)]
        public string? Description { get; set; }
        
        [Required]
        [Range(0, double.MaxValue)]
        public decimal Price { get; set; }
        
        [Range(0, double.MaxValue)]
        public decimal? DiscountedPrice { get; set; }
        
        [Required]
        [Range(0, int.MaxValue)]
        public int StockQuantity { get; set; }
        
        [Range(0, int.MaxValue)]
        public int? MinimumStockLevel { get; set; }
        
        public string? SKU { get; set; }
        
        public string? Brand { get; set; }
        
        public string? Model { get; set; }
        
        public string? Color { get; set; }
        
        public string? Size { get; set; }
        
        public string? Weight { get; set; }
        
        public string? Dimensions { get; set; }
        
        public bool IsActive { get; set; } = true;
        
        public bool IsFeatured { get; set; } = false;
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        public DateTime? UpdatedAt { get; set; }
        
        // Foreign keys
        public int CategoryId { get; set; }
        
        // Navigation properties
        public Category Category { get; set; } = null!;
        public ICollection<ProductImage> ProductImages { get; set; } = new List<ProductImage>();
        public ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();
        public ICollection<CartItem> CartItems { get; set; } = new List<CartItem>();
    }
} 