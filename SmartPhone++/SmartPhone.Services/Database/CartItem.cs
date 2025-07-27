using System;
using System.ComponentModel.DataAnnotations;

namespace SmartPhone.Services.Database
{
    public class CartItem
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        [Range(1, int.MaxValue)]
        public int Quantity { get; set; }
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        public DateTime? UpdatedAt { get; set; }
        
        // Foreign keys
        public int CartId { get; set; }
        public int ProductId { get; set; }
        
        // Navigation properties
        public Cart Cart { get; set; } = null!;
        public Product Product { get; set; } = null!;
    }
} 