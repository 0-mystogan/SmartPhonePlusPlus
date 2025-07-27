using System.ComponentModel.DataAnnotations;

namespace SmartPhone.Model.Requests
{
    public class ProductUpsertRequest
    {
        [Required]
        [MaxLength(200)]
        public string Name { get; set; } = string.Empty;
        
        [MaxLength(1000)]
        public string? Description { get; set; }
        
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
        
        [Required]
        public int CategoryId { get; set; }
    }
} 