using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace SmartPhone.Services.Database
{
    public class Service
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        [MaxLength(200)]
        public string Name { get; set; } = string.Empty;
        
        [MaxLength(1000)]
        public string? Description { get; set; }
        
        [Required]
        [Range(0, double.MaxValue)]
        public decimal ServiceFee { get; set; }
        
        [Range(0, double.MaxValue)]
        public decimal? EstimatedDuration { get; set; } // in hours
        
        [MaxLength(50)]
        public string Status { get; set; } = "Pending"; // Pending, In Progress, Completed, Cancelled
        
        [MaxLength(500)]
        public string? CustomerNotes { get; set; }
        
        [MaxLength(500)]
        public string? TechnicianNotes { get; set; }
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        public DateTime? UpdatedAt { get; set; }
        
        public DateTime? StartedAt { get; set; }
        
        public DateTime? CompletedAt { get; set; }
        
        // Foreign keys
        public int UserId { get; set; } // Customer
        public int? TechnicianId { get; set; } // Technician assigned
        public int? PhoneModelId { get; set; }
        
        // Navigation properties
        public User User { get; set; } = null!;
        public User? Technician { get; set; }
        public PhoneModel? PhoneModel { get; set; }
        public ICollection<ServicePart> ServiceParts { get; set; } = new List<ServicePart>();
    }
} 