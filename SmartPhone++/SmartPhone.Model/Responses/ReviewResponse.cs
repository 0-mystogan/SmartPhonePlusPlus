using System;

namespace SmartPhone.Model.Responses
{
    public class ReviewResponse
    {
        public int Id { get; set; }
        public int Rating { get; set; }
        public string? Comment { get; set; }
        public bool IsApproved { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public DateTime? ApprovedAt { get; set; }
        public int UserId { get; set; }
        public int ProductId { get; set; }
        public int? OrderId { get; set; }
        public string UserName { get; set; } = string.Empty;
        public string ProductName { get; set; } = string.Empty;
        public string? OrderNumber { get; set; }
    }
} 