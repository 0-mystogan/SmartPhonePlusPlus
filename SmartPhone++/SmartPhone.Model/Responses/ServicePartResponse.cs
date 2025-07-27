using System;

namespace SmartPhone.Model.Responses
{
    public class ServicePartResponse
    {
        public int Id { get; set; }
        public int Quantity { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal? DiscountAmount { get; set; }
        public decimal TotalPrice { get; set; }
        public string? Notes { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public int ServiceId { get; set; }
        public int PartId { get; set; }
        public string ServiceName { get; set; } = string.Empty;
        public string PartName { get; set; } = string.Empty;
    }
} 