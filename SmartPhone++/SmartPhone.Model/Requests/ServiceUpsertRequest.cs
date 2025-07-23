using System.ComponentModel.DataAnnotations;

namespace SmartPhone.Model.Requests
{
    public class ServiceUpsertRequest
    {
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        public string Status { get; set; } = string.Empty;
    }
} 