using System;
using System.ComponentModel.DataAnnotations;

namespace SmartPhone.Services.Database
{
    public class ServicePart
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
        
        [MaxLength(500)]
        public string? Notes { get; set; }
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        public DateTime? UpdatedAt { get; set; }
        
        // Foreign keys
        public int ServiceId { get; set; }
        public int PartId { get; set; }
        
        // Navigation properties
        public Service Service { get; set; } = null!;
        public Part Part { get; set; } = null!;
    }
} 