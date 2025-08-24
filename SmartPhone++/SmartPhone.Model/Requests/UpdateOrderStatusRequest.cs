using System.ComponentModel.DataAnnotations;

namespace SmartPhone.Model.Requests
{
    public class UpdateOrderStatusRequest
    {
        [Required]
        [MaxLength(50)]
        public string Status { get; set; } = string.Empty;
        
        [MaxLength(500)]
        public string? Notes { get; set; }
    }
}
