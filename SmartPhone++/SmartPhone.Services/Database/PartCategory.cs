using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace SmartPhone.Services.Database
{
    public class PartCategory
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;
        
        [MaxLength(500)]
        public string? Description { get; set; }
        
        public string? ImageUrl { get; set; }
        
        public bool IsActive { get; set; } = true;
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        public DateTime? UpdatedAt { get; set; }
        
        // Self-referencing relationship for subcategories
        public int? ParentCategoryId { get; set; }
        public PartCategory? ParentCategory { get; set; }
        public ICollection<PartCategory> SubCategories { get; set; } = new List<PartCategory>();
        
        // Navigation property for parts
        public ICollection<Part> Parts { get; set; } = new List<Part>();
    }
} 