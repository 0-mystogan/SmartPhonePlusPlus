using System;
using SmartPhone.Model.SearchObjects;

namespace SmartPhone.Model.SearchObjects
{
    public class ReviewSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? ProductId { get; set; }
        public int? OrderId { get; set; }
        public int? Rating { get; set; }
        public bool? IsApproved { get; set; }
        public DateTime? FromDate { get; set; }
        public DateTime? ToDate { get; set; }
    }
} 