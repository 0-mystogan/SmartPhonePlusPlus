using System;
using SmartPhone.Model.SearchObjects;

namespace SmartPhone.Model.SearchObjects
{
    public class OrderStatusHistorySearchObject : BaseSearchObject
    {
        public int? OrderId { get; set; }
        public int? UpdatedByUserId { get; set; }
        public string? Status { get; set; }
        public DateTime? FromDate { get; set; }
        public DateTime? ToDate { get; set; }
    }
} 