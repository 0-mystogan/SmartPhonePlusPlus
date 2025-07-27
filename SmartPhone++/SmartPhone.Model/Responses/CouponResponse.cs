using System;

namespace SmartPhone.Model.Responses
{
    public class CouponResponse
    {
        public int Id { get; set; }
        public string Code { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public decimal DiscountAmount { get; set; }
        public string DiscountType { get; set; } = string.Empty;
        public decimal? MaximumDiscountAmount { get; set; }
        public decimal? MinimumOrderAmount { get; set; }
        public DateTime ValidFrom { get; set; }
        public DateTime ValidTo { get; set; }
        public int? MaximumUses { get; set; }
        public int CurrentUses { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public bool IsValid { get; set; }
        public bool IsExpired { get; set; }
        public bool IsUsageLimitReached { get; set; }
    }
} 