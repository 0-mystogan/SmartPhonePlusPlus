using System;
using System.ComponentModel.DataAnnotations;

namespace SmartPhone.Services.Database
{
    public class OrderStatusHistory
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        [MaxLength(50)]
        public string Status { get; set; } = string.Empty;
        
        [MaxLength(500)]
        public string? Notes { get; set; }
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        // Foreign keys
        public int OrderId { get; set; }
        public int? UpdatedByUserId { get; set; }
        
        // Navigation properties
        public Order Order { get; set; } = null!;
        public User? UpdatedByUser { get; set; }
    }
} 