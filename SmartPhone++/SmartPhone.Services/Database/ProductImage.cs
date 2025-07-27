using System;
using System.ComponentModel.DataAnnotations;

namespace SmartPhone.Services.Database
{
    public class ProductImage
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        public string ImageUrl { get; set; } = string.Empty;
        
        [MaxLength(200)]
        public string? AltText { get; set; }
        
        public bool IsPrimary { get; set; } = false;
        
        public int DisplayOrder { get; set; } = 0;
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        // Foreign key
        public int ProductId { get; set; }
        
        // Navigation property
        public Product Product { get; set; } = null!;
    }
} 