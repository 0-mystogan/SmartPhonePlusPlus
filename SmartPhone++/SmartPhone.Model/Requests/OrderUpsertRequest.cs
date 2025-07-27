using System.ComponentModel.DataAnnotations;

namespace SmartPhone.Model.Requests
{
    public class OrderUpsertRequest
    {
        [Required]
        [MaxLength(50)]
        public string OrderNumber { get; set; } = string.Empty;
        
        [Required]
        [Range(0, double.MaxValue)]
        public decimal Subtotal { get; set; }
        
        [Range(0, double.MaxValue)]
        public decimal TaxAmount { get; set; }
        
        [Range(0, double.MaxValue)]
        public decimal ShippingAmount { get; set; }
        
        [Range(0, double.MaxValue)]
        public decimal DiscountAmount { get; set; }
        
        [Required]
        [Range(0, double.MaxValue)]
        public decimal TotalAmount { get; set; }
        
        [Required]
        [MaxLength(3)]
        public string CurrencyCode { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(5)]
        public string CurrencySymbol { get; set; } = string.Empty;
        
        [MaxLength(50)]
        public string Status { get; set; } = "Pending";
        
        [MaxLength(500)]
        public string? Notes { get; set; }
        
        [MaxLength(100)]
        public string? TrackingNumber { get; set; }
        
        // Shipping information
        [Required]
        [MaxLength(100)]
        public string ShippingFirstName { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(100)]
        public string ShippingLastName { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(200)]
        public string ShippingAddress { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(100)]
        public string ShippingCity { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(20)]
        public string ShippingPostalCode { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(100)]
        public string ShippingCountry { get; set; } = string.Empty;
        
        [Required]
        [Phone]
        [MaxLength(20)]
        public string ShippingPhone { get; set; } = string.Empty;
        
        [EmailAddress]
        [MaxLength(100)]
        public string? ShippingEmail { get; set; }
        
        // Billing information
        [Required]
        [MaxLength(100)]
        public string BillingFirstName { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(100)]
        public string BillingLastName { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(200)]
        public string BillingAddress { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(100)]
        public string BillingCity { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(20)]
        public string BillingPostalCode { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(100)]
        public string BillingCountry { get; set; } = string.Empty;
        
        [Required]
        [Phone]
        [MaxLength(20)]
        public string BillingPhone { get; set; } = string.Empty;
        
        [EmailAddress]
        [MaxLength(100)]
        public string? BillingEmail { get; set; }
        
        [Required]
        public int UserId { get; set; }
        
        public int? CouponId { get; set; }
    }
} 