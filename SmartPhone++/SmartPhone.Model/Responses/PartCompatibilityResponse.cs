using System;

namespace SmartPhone.Model.Responses
{
    public class PartCompatibilityResponse
    {
        public int Id { get; set; }
        public string? Notes { get; set; }
        public bool IsVerified { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public int PartId { get; set; }
        public int PhoneModelId { get; set; }
        public string PartName { get; set; } = string.Empty;
        public string PhoneModelName { get; set; } = string.Empty;
    }
} 