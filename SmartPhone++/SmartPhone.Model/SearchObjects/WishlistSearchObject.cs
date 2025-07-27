using System;
using SmartPhone.Model.SearchObjects;

namespace SmartPhone.Model.SearchObjects
{
    public class WishlistSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public DateTime? FromDate { get; set; }
        public DateTime? ToDate { get; set; }
    }
} 