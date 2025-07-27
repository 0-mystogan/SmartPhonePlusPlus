using System;
using System.ComponentModel.DataAnnotations;

namespace SmartPhone.Model.Requests
{
    public class CouponUpsertRequest
    {
        [Required]
        [MaxLength(50)]
        public string Code { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(200)]
        public string Name { get; set; } = string.Empty;
        
        [MaxLength(500)]
        public string? Description { get; set; }
        
        [Required]
        public decimal DiscountAmount { get; set; }
        
        [Required]
        public string DiscountType { get; set; } = "Percentage";
        
        [Range(0, 100)]
        public decimal? MaximumDiscountAmount { get; set; }
        
        [Range(0, double.MaxValue)]
        public decimal? MinimumOrderAmount { get; set; }
        
        public DateTime ValidFrom { get; set; }
        
        public DateTime ValidTo { get; set; }
        
        public int? MaximumUses { get; set; }
        
        public bool IsActive { get; set; } = true;
    }
} 