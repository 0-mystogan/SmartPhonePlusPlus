using System;
using System.ComponentModel.DataAnnotations;

namespace SmartPhone.Services.Database
{
    public class Review
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        [Range(1, 5)]
        public int Rating { get; set; }
        
        [MaxLength(1000)]
        public string? Comment { get; set; }
        
        public bool IsApproved { get; set; } = false;
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        public DateTime? UpdatedAt { get; set; }
        
        public DateTime? ApprovedAt { get; set; }
        
        // Foreign keys
        public int UserId { get; set; }
        public int ProductId { get; set; }
        public int? OrderId { get; set; } // Optional: link to specific order
        
        // Navigation properties
        public User User { get; set; } = null!;
        public Product Product { get; set; } = null!;
        public Order? Order { get; set; }
    }
} 