using System.ComponentModel.DataAnnotations;

namespace SmartPhone.Model.Requests
{
    public class OrderStatusHistoryUpsertRequest
    {
        [Required]
        [MaxLength(50)]
        public string Status { get; set; } = string.Empty;
        
        [MaxLength(500)]
        public string? Notes { get; set; }
        
        [Required]
        public int OrderId { get; set; }
        
        public int? UpdatedByUserId { get; set; }
    }
} 