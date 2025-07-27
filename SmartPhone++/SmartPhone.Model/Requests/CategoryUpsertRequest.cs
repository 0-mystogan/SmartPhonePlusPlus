using System.ComponentModel.DataAnnotations;

namespace SmartPhone.Model.Requests
{
    public class CategoryUpsertRequest
    {
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;
        
        [MaxLength(500)]
        public string? Description { get; set; }
        
        public string? ImageUrl { get; set; }
        
        public bool IsActive { get; set; } = true;
        
        public int? ParentCategoryId { get; set; }
    }
} 