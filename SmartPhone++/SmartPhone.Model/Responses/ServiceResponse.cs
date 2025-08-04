using System;

namespace SmartPhone.Model.Responses
{
    public class ServiceResponse
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public double ServiceFee { get; set; }
        public decimal? EstimatedDuration { get; set; }
        public string Status { get; set; } = string.Empty;
        public string? CustomerNotes { get; set; }
        public string? TechnicianNotes { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public DateTime? StartedAt { get; set; }
        public DateTime? CompletedAt { get; set; }
        public int UserId { get; set; }
        public int? TechnicianId { get; set; }
        public int? PhoneModelId { get; set; }
        
        // Navigation properties
        public string? UserName { get; set; }
        public string? TechnicianName { get; set; }
        public string? PhoneModelName { get; set; }
    }
} 