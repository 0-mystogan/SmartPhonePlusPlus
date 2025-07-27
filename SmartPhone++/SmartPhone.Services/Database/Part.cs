using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace SmartPhone.Services.Database
{
    public class Part
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
        public decimal? CostPrice { get; set; }
        
        [Required]
        [Range(0, int.MaxValue)]
        public int StockQuantity { get; set; }
        
        [Range(0, int.MaxValue)]
        public int? MinimumStockLevel { get; set; }
        
        public string? SKU { get; set; }
        
        public string? PartNumber { get; set; }
        
        public string? Brand { get; set; }
        
        public string? Model { get; set; }
        
        public string? Color { get; set; }
        
        [MaxLength(50)]
        public string? Condition { get; set; } // New, Used, Refurbished, OEM, Aftermarket
        
        [MaxLength(50)]
        public string? Grade { get; set; } // A, B, C, D
        
        public bool IsActive { get; set; } = true;
        
        public bool IsOEM { get; set; } = false;
        
        public bool IsCompatible { get; set; } = true;
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        public DateTime? UpdatedAt { get; set; }
        
        // Foreign keys
        public int PartCategoryId { get; set; }
        
        // Navigation properties
        public PartCategory PartCategory { get; set; } = null!;
        public ICollection<ServicePart> ServiceParts { get; set; } = new List<ServicePart>();
        public ICollection<PartCompatibility> CompatiblePhones { get; set; } = new List<PartCompatibility>();
    }
} 