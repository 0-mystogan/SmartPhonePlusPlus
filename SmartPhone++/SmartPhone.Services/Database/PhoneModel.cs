using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace SmartPhone.Services.Database
{
    public class PhoneModel
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        [MaxLength(100)]
        public string Brand { get; set; } = string.Empty; // Apple, Samsung, Xiaomi, etc.
        
        [Required]
        [MaxLength(100)]
        public string Model { get; set; } = string.Empty; // iPhone 15 Pro, Galaxy S24 Ultra, etc.
        
        [MaxLength(100)]
        public string? Series { get; set; } // Pro, Ultra, Plus, etc.
        
        [MaxLength(50)]
        public string? Year { get; set; }
        
        [MaxLength(100)]
        public string? Color { get; set; }
        
        [MaxLength(50)]
        public string? Storage { get; set; } // 128GB, 256GB, etc.
        
        [MaxLength(50)]
        public string? RAM { get; set; } // 8GB, 12GB, etc.
        
        [MaxLength(100)]
        public string? Network { get; set; } // 4G, 5G, etc.
        
        public string? ImageUrl { get; set; }
        
        public bool IsActive { get; set; } = true;
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        public DateTime? UpdatedAt { get; set; }
        
        // Navigation properties
        public ICollection<PartCompatibility> CompatibleParts { get; set; } = new List<PartCompatibility>();
        public ICollection<Service> Services { get; set; } = new List<Service>();
    }
} 