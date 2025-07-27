using System;
using System.ComponentModel.DataAnnotations;

namespace SmartPhone.Model.Requests
{
    public class ProductPriceUpsertRequest
    {
        [Required]
        [Range(0, double.MaxValue)]
        public decimal Price { get; set; }
        
        [Range(0, double.MaxValue)]
        public decimal? DiscountedPrice { get; set; }
        
        public DateTime? ValidFrom { get; set; }
        
        public DateTime? ValidTo { get; set; }
        
        public bool IsActive { get; set; } = true;
        
        [Required]
        public int ProductId { get; set; }
        
        [Required]
        public int CurrencyId { get; set; }
    }
} 