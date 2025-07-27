using SmartPhone.Model.SearchObjects;

namespace SmartPhone.Model.SearchObjects
{
    public class WishlistItemSearchObject : BaseSearchObject
    {
        public int? WishlistId { get; set; }
        public int? ProductId { get; set; }
        public int? UserId { get; set; }
    }
} 