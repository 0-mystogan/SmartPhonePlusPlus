using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace SmartPhone.Services.Database
{
    public class Currency
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        [MaxLength(3)]
        public string Code { get; set; } = string.Empty; // USD, EUR, BAM, etc.
        
        [Required]
        [MaxLength(50)]
        public string Name { get; set; } = string.Empty; // US Dollar, Euro, Bosnia and Herzegovina Convertible Mark
        
        [Required]
        [MaxLength(5)]
        public string Symbol { get; set; } = string.Empty; // $, €, KM
        
        [MaxLength(10)]
        public string? SymbolPosition { get; set; } = "Before"; // Before, After
        
        [Range(0, 10)]
        public int DecimalPlaces { get; set; } = 2;
        
        public bool IsActive { get; set; } = true;
        
        public bool IsDefault { get; set; } = false;
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        public DateTime? UpdatedAt { get; set; }
        
        // Navigation properties
        public ICollection<ProductPrice> ProductPrices { get; set; } = new List<ProductPrice>();
    }
} 