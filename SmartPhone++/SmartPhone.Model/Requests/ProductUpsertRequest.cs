using System.ComponentModel.DataAnnotations;
using System.Collections.Generic;

namespace SmartPhone.Model.Requests
{
    public class ProductUpsertRequest
    {
        [MaxLength(200)]
        public string? Name { get; set; }
        
        [MaxLength(1000)]
        public string? Description { get; set; }
        
        [Range(0, double.MaxValue)]
        public decimal? Price { get; set; }
        
        [Range(0, double.MaxValue)]
        public decimal? DiscountedPrice { get; set; }
        
        [Range(0, int.MaxValue)]
        public int? StockQuantity { get; set; }
        
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
        
        public int? CategoryId { get; set; }
        
        // Simple base64 string array for images (like user's Picture property)
        public List<string> Images { get; set; } = new List<string>();
        
        // Keep the complex approach for backward compatibility
        public List<ProductImageUpsertRequest> ProductImages { get; set; } = new List<ProductImageUpsertRequest>();
    }
} 