using System;

namespace SmartPhone.Model.Responses
{
    public class WishlistResponse
    {
        public int Id { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public int UserId { get; set; }
        public string UserName { get; set; } = string.Empty;
        public int ItemCount { get; set; }
    }
} 