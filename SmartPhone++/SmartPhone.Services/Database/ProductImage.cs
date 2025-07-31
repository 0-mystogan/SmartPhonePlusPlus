using System;
using System.ComponentModel.DataAnnotations;

namespace SmartPhone.Services.Database
{
    public class ProductImage
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        public byte[] ImageData { get; set; } = new byte[0];
        
        [MaxLength(50)]
        public string? FileName { get; set; }
        
        [MaxLength(20)]
        public string? ContentType { get; set; }
        
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