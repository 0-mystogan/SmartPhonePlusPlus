using System;
using System.ComponentModel.DataAnnotations;

namespace SmartPhone.Services.Database
{
    public class PartCompatibility
    {
        [Key]
        public int Id { get; set; }
        
        [MaxLength(500)]
        public string? Notes { get; set; }
        
        public bool IsVerified { get; set; } = false;
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        public DateTime? UpdatedAt { get; set; }
        
        // Foreign keys
        public int PartId { get; set; }
        public int PhoneModelId { get; set; }
        
        // Navigation properties
        public Part Part { get; set; } = null!;
        public PhoneModel PhoneModel { get; set; } = null!;
    }
} 