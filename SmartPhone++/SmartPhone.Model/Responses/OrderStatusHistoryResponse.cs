using System;

namespace SmartPhone.Model.Responses
{
    public class OrderStatusHistoryResponse
    {
        public int Id { get; set; }
        public string Status { get; set; } = string.Empty;
        public string? Notes { get; set; }
        public DateTime CreatedAt { get; set; }
        public int OrderId { get; set; }
        public int? UpdatedByUserId { get; set; }
        public string OrderNumber { get; set; } = string.Empty;
        public string? UpdatedByUserName { get; set; }
    }
} 