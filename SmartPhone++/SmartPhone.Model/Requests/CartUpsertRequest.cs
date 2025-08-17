
using System;
using System.ComponentModel.DataAnnotations;

namespace SmartPhone.Model.Requests
{
    public class CartUpsertRequest
    {
        public DateTime? ExpiresAt { get; set; }
        public bool IsActive { get; set; } = true;
        public int UserId { get; set; }
    }
} 