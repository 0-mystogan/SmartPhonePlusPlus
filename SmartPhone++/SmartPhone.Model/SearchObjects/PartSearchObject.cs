using SmartPhone.Model.SearchObjects;

namespace SmartPhone.Model.SearchObjects
{
    public class PartSearchObject : BaseSearchObject
    {
        public string? Name { get; set; }
        public string? Brand { get; set; }
        public string? SKU { get; set; }
        public string? PartNumber { get; set; }
        public int? PartCategoryId { get; set; }
        public bool? IsActive { get; set; }
        public bool? IsOEM { get; set; }
        public decimal? MinPrice { get; set; }
        public decimal? MaxPrice { get; set; }
        public bool? InStock { get; set; }
    }
} 