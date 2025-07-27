using SmartPhone.Model.SearchObjects;

namespace SmartPhone.Model.SearchObjects
{
    public class OrderItemSearchObject : BaseSearchObject
    {
        public int? OrderId { get; set; }
        public int? ProductId { get; set; }
        public decimal? MinTotalPrice { get; set; }
        public decimal? MaxTotalPrice { get; set; }
        public string? CurrencyCode { get; set; }
    }
} 