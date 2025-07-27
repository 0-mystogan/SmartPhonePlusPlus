using System;
using SmartPhone.Model.SearchObjects;

namespace SmartPhone.Model.SearchObjects
{
    public class CouponSearchObject : BaseSearchObject
    {
        public string? Code { get; set; }
        public string? Name { get; set; }
        public string? DiscountType { get; set; }
        public bool? IsActive { get; set; }
        public DateTime? ValidFrom { get; set; }
        public DateTime? ValidTo { get; set; }
        public bool? IsExpired { get; set; }
    }
} 