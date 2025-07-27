using System.ComponentModel.DataAnnotations;

namespace SmartPhone.Model.Requests
{
    public class WishlistItemUpsertRequest
    {
        [Required]
        public int WishlistId { get; set; }
        
        [Required]
        public int ProductId { get; set; }
    }
} 