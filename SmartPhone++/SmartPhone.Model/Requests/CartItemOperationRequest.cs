using System.ComponentModel.DataAnnotations;

namespace SmartPhone.Model.Requests
{
    public class CartItemOperationRequest
    {
        [Required]
        [Range(1, int.MaxValue)]
        public int ProductId { get; set; }
        
        [Required]
        [Range(0, int.MaxValue)] // Allow 0 for removal operations
        public int Quantity { get; set; }
    }
}
