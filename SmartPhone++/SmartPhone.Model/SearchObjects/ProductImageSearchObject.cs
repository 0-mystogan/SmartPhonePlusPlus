using SmartPhone.Model.SearchObjects;

namespace SmartPhone.Model.SearchObjects
{
    public class ProductImageSearchObject : BaseSearchObject
    {
        public int? ProductId { get; set; }
        public bool? IsPrimary { get; set; }
    }
} 