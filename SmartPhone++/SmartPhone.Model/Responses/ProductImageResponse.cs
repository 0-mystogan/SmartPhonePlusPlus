using System;

namespace SmartPhone.Model.Responses
{
    public class ProductImageResponse
    {
        public int Id { get; set; }
        public byte[] ImageData { get; set; } = new byte[0];
        public string? FileName { get; set; }
        public string? ContentType { get; set; }
        public string? AltText { get; set; }
        public bool IsPrimary { get; set; }
        public int DisplayOrder { get; set; }
        public DateTime CreatedAt { get; set; }
        public int ProductId { get; set; }
        public string ProductName { get; set; } = string.Empty;
    }
} 