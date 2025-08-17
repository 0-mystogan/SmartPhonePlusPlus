using SmartPhone.Model.SearchObjects;

namespace SmartPhone.Model.SearchObjects
{
    public class CartItemSearchObject : BaseSearchObject
    {
        public int? CartId { get; set; }
        public int? ProductId { get; set; }
    }
} 