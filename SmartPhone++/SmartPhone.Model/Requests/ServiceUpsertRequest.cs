using System.ComponentModel.DataAnnotations;
using System;

namespace SmartPhone.Model.Requests
{
    public class ServiceUpsertRequest
    {
        [Required]
        [MaxLength(200)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(1000)]
        public string? Description { get; set; }

        [Required]
        [Range(0, double.MaxValue)]
        public double ServiceFee { get; set; }

        [Range(0, double.MaxValue)]
        public decimal? EstimatedDuration { get; set; }

        [MaxLength(50)]
        public string Status { get; set; } = "Pending";

        [MaxLength(500)]
        public string? CustomerNotes { get; set; }

        [MaxLength(500)]
        public string? TechnicianNotes { get; set; }

        public DateTime? UpdatedAt { get; set; }

        public DateTime? StartedAt { get; set; }

        public DateTime? CompletedAt { get; set; }

        [Required]
        public int UserId { get; set; }

        public int? TechnicianId { get; set; }

        public int? PhoneModelId { get; set; }
    }
} 