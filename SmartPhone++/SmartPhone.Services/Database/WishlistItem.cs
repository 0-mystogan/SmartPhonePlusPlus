using System;
using System.ComponentModel.DataAnnotations;

namespace SmartPhone.Services.Database
{
    public class WishlistItem
    {
        [Key]
        public int Id { get; set; }
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        // Foreign keys
        public int WishlistId { get; set; }
        public int ProductId { get; set; }
        
        // Navigation properties
        public Wishlist Wishlist { get; set; } = null!;
        public Product Product { get; set; } = null!;
    }
} 