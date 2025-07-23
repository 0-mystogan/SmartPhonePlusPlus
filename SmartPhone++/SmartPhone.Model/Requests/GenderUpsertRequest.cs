using System.ComponentModel.DataAnnotations;

namespace SmartPhone.Model.Requests
{
    public class GenderUpsertRequest
    {
        [Required]
        [MaxLength(50)]
        public string Name { get; set; } = string.Empty;
    }
} 