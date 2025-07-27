using System.ComponentModel.DataAnnotations;

namespace SmartPhone.Model.Requests
{
    public class ReviewUpsertRequest
    {
        [Required]
        [Range(1, 5)]
        public int Rating { get; set; }
        
        [MaxLength(1000)]
        public string? Comment { get; set; }
        
        public bool IsApproved { get; set; } = false;
        
        [Required]
        public int UserId { get; set; }
        
        [Required]
        public int ProductId { get; set; }
        
        public int? OrderId { get; set; }
    }
} 