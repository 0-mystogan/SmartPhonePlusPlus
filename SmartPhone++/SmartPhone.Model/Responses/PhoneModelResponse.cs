using System;

namespace SmartPhone.Model.Responses
{
    public class PhoneModelResponse
    {
        public int Id { get; set; }
        public string Brand { get; set; } = string.Empty;
        public string Model { get; set; } = string.Empty;
        public string? Series { get; set; }
        public string? Year { get; set; }
        public string? Color { get; set; }
        public string? Storage { get; set; }
        public string? RAM { get; set; }
        public string? Network { get; set; }
        public string? ImageUrl { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }
} 