using SmartPhone.Model.SearchObjects;

namespace SmartPhone.Model.SearchObjects
{
    public class ProductSearchObject : BaseSearchObject
    {
        public string? Name { get; set; }
        public string? Brand { get; set; }
        public string? SKU { get; set; }
        public int? CategoryId { get; set; }
        public bool? IsActive { get; set; }
        public bool? IsFeatured { get; set; }
        public decimal? MinPrice { get; set; }
        public decimal? MaxPrice { get; set; }
        public bool? InStock { get; set; }
        public double? MinRating { get; set; }
    }
} 