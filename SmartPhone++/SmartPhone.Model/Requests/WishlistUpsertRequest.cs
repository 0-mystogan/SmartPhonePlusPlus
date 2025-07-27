using System.ComponentModel.DataAnnotations;

namespace SmartPhone.Model.Requests
{
    public class WishlistUpsertRequest
    {
        [Required]
        public int UserId { get; set; }
    }
} 