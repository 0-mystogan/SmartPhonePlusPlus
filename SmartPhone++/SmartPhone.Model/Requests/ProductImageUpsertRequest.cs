using System.ComponentModel.DataAnnotations;

namespace SmartPhone.Model.Requests
{
    public class ProductImageUpsertRequest
    {
        [Required]
        public string ImageUrl { get; set; } = string.Empty;
        
        [MaxLength(200)]
        public string? AltText { get; set; }
        
        public bool IsPrimary { get; set; } = false;
        
        public int DisplayOrder { get; set; } = 0;
        
        [Required]
        public int ProductId { get; set; }
    }
} 