using System.ComponentModel.DataAnnotations;

namespace SmartPhone.Model.Requests
{
    public class PartCompatibilityUpsertRequest
    {
        [Required]
        public int PartId { get; set; }
        
        [Required]
        public int PhoneModelId { get; set; }
        
        [MaxLength(500)]
        public string? Notes { get; set; }
        
        public bool IsVerified { get; set; } = false;
    }
} 