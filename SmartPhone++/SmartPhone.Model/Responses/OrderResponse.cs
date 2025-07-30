using System;

namespace SmartPhone.Model.Responses
{
    public class OrderResponse
    {
        public int Id { get; set; }
        public string OrderNumber { get; set; } = string.Empty;
        public DateTime OrderDate { get; set; }
        public DateTime? ShippedDate { get; set; }
        public DateTime? DeliveredDate { get; set; }
        public decimal Subtotal { get; set; }
        public decimal TaxAmount { get; set; }
        public decimal ShippingAmount { get; set; }
        public decimal DiscountAmount { get; set; }
        public decimal TotalAmount { get; set; }
        public string Status { get; set; } = string.Empty;
        public string? Notes { get; set; }
        public string? TrackingNumber { get; set; }
        
        // Shipping information
        public string ShippingFirstName { get; set; } = string.Empty;
        public string ShippingLastName { get; set; } = string.Empty;
        public string ShippingAddress { get; set; } = string.Empty;
        public string ShippingCity { get; set; } = string.Empty;
        public string ShippingPostalCode { get; set; } = string.Empty;
        public string ShippingCountry { get; set; } = string.Empty;
        public string ShippingPhone { get; set; } = string.Empty;
        public string? ShippingEmail { get; set; }
        
        // Billing information
        public string BillingFirstName { get; set; } = string.Empty;
        public string BillingLastName { get; set; } = string.Empty;
        public string BillingAddress { get; set; } = string.Empty;
        public string BillingCity { get; set; } = string.Empty;
        public string BillingPostalCode { get; set; } = string.Empty;
        public string BillingCountry { get; set; } = string.Empty;
        public string BillingPhone { get; set; } = string.Empty;
        public string? BillingEmail { get; set; }
        
        public int UserId { get; set; }
        public string UserName { get; set; } = string.Empty;
        public int ItemCount { get; set; }
    }
} 