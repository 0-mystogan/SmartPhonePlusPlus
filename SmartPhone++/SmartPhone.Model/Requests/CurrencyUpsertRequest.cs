using System.ComponentModel.DataAnnotations;

namespace SmartPhone.Model.Requests
{
    public class CurrencyUpsertRequest
    {
        [Required]
        [MaxLength(3)]
        public string Code { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(50)]
        public string Name { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(5)]
        public string Symbol { get; set; } = string.Empty;
        
        [MaxLength(10)]
        public string? SymbolPosition { get; set; } = "Before";
        
        [Range(0, 10)]
        public int DecimalPlaces { get; set; } = 2;
        
        public bool IsActive { get; set; } = true;
        
        public bool IsDefault { get; set; } = false;
    }
} 