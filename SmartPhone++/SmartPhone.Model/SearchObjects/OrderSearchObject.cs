using System;
using SmartPhone.Model.SearchObjects;

namespace SmartPhone.Model.SearchObjects
{
    public class OrderSearchObject : BaseSearchObject
    {
        public string? OrderNumber { get; set; }
        public string? Status { get; set; }
        public int? UserId { get; set; }
        public DateTime? OrderDateFrom { get; set; }
        public DateTime? OrderDateTo { get; set; }
        public decimal? MinTotalAmount { get; set; }
        public decimal? MaxTotalAmount { get; set; }
        public string? ShippingFirstName { get; set; }
        public string? ShippingLastName { get; set; }
        public string? BillingFirstName { get; set; }
        public string? BillingLastName { get; set; }
    }
} 