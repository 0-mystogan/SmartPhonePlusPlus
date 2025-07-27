using System.ComponentModel.DataAnnotations;

namespace SmartPhone.Model.Requests
{
    public class ServicePartUpsertRequest
    {
        [Required]
        [Range(1, int.MaxValue)]
        public int Quantity { get; set; }
        
        [Required]
        [Range(0, double.MaxValue)]
        public decimal UnitPrice { get; set; }
        
        [Range(0, double.MaxValue)]
        public decimal? DiscountAmount { get; set; }
        
        [Required]
        [Range(0, double.MaxValue)]
        public decimal TotalPrice { get; set; }
        
        [MaxLength(500)]
        public string? Notes { get; set; }
        
        [Required]
        public int ServiceId { get; set; }
        
        [Required]
        public int PartId { get; set; }
    }
} 