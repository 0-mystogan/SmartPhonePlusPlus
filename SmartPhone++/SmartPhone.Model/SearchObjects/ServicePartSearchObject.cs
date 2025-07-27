using SmartPhone.Model.SearchObjects;

namespace SmartPhone.Model.SearchObjects
{
    public class ServicePartSearchObject : BaseSearchObject
    {
        public int? ServiceId { get; set; }
        public int? PartId { get; set; }
        public decimal? MinTotalPrice { get; set; }
        public decimal? MaxTotalPrice { get; set; }
    }
} 