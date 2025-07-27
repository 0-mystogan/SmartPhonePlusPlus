using System;
using SmartPhone.Model.SearchObjects;

namespace SmartPhone.Model.SearchObjects
{
    public class OrderSearchObject : BaseSearchObject
    {
        public string? OrderNumber { get; set; }
        public int? UserId { get; set; }
        public string? Status { get; set; }
        public DateTime? FromDate { get; set; }
        public DateTime? ToDate { get; set; }
        public decimal? MinTotalAmount { get; set; }
        public decimal? MaxTotalAmount { get; set; }
        public string? CurrencyCode { get; set; }
    }
} 