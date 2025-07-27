using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace SmartPhone.Services.Database
{
    public class Coupon
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        [MaxLength(50)]
        public string Code { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(200)]
        public string Name { get; set; } = string.Empty;
        
        [MaxLength(500)]
        public string? Description { get; set; }
        
        [Required]
        public decimal DiscountAmount { get; set; }
        
        [Required]
        public string DiscountType { get; set; } = "Percentage"; // Percentage, FixedAmount
        
        [Range(0, 100)]
        public decimal? MaximumDiscountAmount { get; set; }
        
        [Range(0, double.MaxValue)]
        public decimal? MinimumOrderAmount { get; set; }
        
        public DateTime ValidFrom { get; set; }
        
        public DateTime ValidTo { get; set; }
        
        public int? MaximumUses { get; set; }
        
        public int CurrentUses { get; set; } = 0;
        
        public bool IsActive { get; set; } = true;
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        public DateTime? UpdatedAt { get; set; }
        
        // Navigation properties
        public ICollection<Order> Orders { get; set; } = new List<Order>();
    }
} 