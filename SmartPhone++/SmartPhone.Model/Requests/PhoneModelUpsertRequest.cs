using System.ComponentModel.DataAnnotations;

namespace SmartPhone.Model.Requests
{
    public class PhoneModelUpsertRequest
    {
        [Required]
        [MaxLength(100)]
        public string Brand { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(100)]
        public string Model { get; set; } = string.Empty;
        
        [MaxLength(100)]
        public string? Series { get; set; }
        
        [MaxLength(50)]
        public string? Year { get; set; }
        
        [MaxLength(100)]
        public string? Color { get; set; }
        
        [MaxLength(50)]
        public string? Storage { get; set; }
        
        [MaxLength(50)]
        public string? RAM { get; set; }
        
        [MaxLength(100)]
        public string? Network { get; set; }
        
        public string? ImageUrl { get; set; }
        
        public bool IsActive { get; set; } = true;
    }
} 