using System;
using System.Collections.Generic;

namespace SmartPhone.Model.Responses
{
    public class ProductResponse
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public int StockQuantity { get; set; }
        public int? MinimumStockLevel { get; set; }
        public string? SKU { get; set; }
        public string? Brand { get; set; }
        public string? Model { get; set; }
        public string? Color { get; set; }
        public string? Size { get; set; }
        public string? Weight { get; set; }
        public string? Dimensions { get; set; }
        public bool IsActive { get; set; }
        public bool IsFeatured { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public int CategoryId { get; set; }
        public string CategoryName { get; set; } = string.Empty;
        public decimal? CurrentPrice { get; set; }
        public decimal? OriginalPrice { get; set; }
        public List<ProductImageResponse> ProductImages { get; set; } = new List<ProductImageResponse>();
    }
} 