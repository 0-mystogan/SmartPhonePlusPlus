using System.ComponentModel.DataAnnotations;
using System;

namespace SmartPhone.Model.Requests
{
    public class ProductImageUpsertRequest
    {
        private byte[] _imageData = new byte[0];
        
        [Required]
        public byte[] ImageData 
        { 
            get => _imageData;
            set => _imageData = value;
        }
        
       
        public string? ImageDataString
        {
            get => Convert.ToBase64String(_imageData);
            set
            {
                if (!string.IsNullOrEmpty(value))
                {
                    try
                    {
                        _imageData = Convert.FromBase64String(value);
                    }
                    catch (FormatException)
                    {
                        // If base64 conversion fails, keep the original byte array
                        // This allows the property to work with both byte[] and base64 string
                    }
                }
            }
        }
        
        [MaxLength(50)]
        public string? FileName { get; set; }
        
        [MaxLength(20)]
        public string? ContentType { get; set; }
        
        [MaxLength(200)]
        public string? AltText { get; set; }
        
        public bool IsPrimary { get; set; } = false;
        
        public int DisplayOrder { get; set; } = 0;
        
        [Required]
        public int ProductId { get; set; }
    }
} 