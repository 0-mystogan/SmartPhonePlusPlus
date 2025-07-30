using System;

namespace SmartPhone.Model.SearchObjects
{
    public class OrderItemSearchObject : BaseSearchObject
    {
        public int? OrderId { get; set; }
        public int? ProductId { get; set; }
        public decimal? MinPrice { get; set; }
        public decimal? MaxPrice { get; set; }
        public int? MinQuantity { get; set; }
        public int? MaxQuantity { get; set; }
    }
} 