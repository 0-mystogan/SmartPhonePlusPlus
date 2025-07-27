using System;

namespace SmartPhone.Model.Responses
{
    public class PartResponse
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public decimal Price { get; set; }
        public decimal? CostPrice { get; set; }
        public int StockQuantity { get; set; }
        public int? MinimumStockLevel { get; set; }
        public string? SKU { get; set; }
        public string? PartNumber { get; set; }
        public string? Brand { get; set; }
        public string? Model { get; set; }
        public string? Color { get; set; }
        public string? Condition { get; set; }
        public string? Grade { get; set; }
        public bool IsActive { get; set; }
        public bool IsOEM { get; set; }
        public bool IsCompatible { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public int PartCategoryId { get; set; }
        public string PartCategoryName { get; set; } = string.Empty;
    }
} 