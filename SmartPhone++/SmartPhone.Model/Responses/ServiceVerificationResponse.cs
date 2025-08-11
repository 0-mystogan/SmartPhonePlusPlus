using System;

namespace SmartPhone.Model.Responses
{
    public class ServiceVerificationResponse
    {
        public int ServiceId { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public decimal ServiceFee { get; set; }
        public string? CustomerNotes { get; set; }
        public DateTime CreatedAt { get; set; }
        public string CustomerName { get; set; } = string.Empty;
        public string? TechnicianName { get; set; }
        public DateTime? EstimatedCompletion { get; set; }
    }
}


