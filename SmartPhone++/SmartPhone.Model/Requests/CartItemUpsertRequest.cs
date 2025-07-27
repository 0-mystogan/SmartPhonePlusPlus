using System.ComponentModel.DataAnnotations;

namespace SmartPhone.Model.Requests
{
    public class CartItemUpsertRequest
    {
        [Required]
        [Range(1, int.MaxValue)]
        public int Quantity { get; set; }
        
        [Required]
        public int CartId { get; set; }
        
        [Required]
        public int ProductId { get; set; }
    }
} 