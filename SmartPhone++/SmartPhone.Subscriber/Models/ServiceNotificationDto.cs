using System.Collections.Generic;

namespace SmartPhone.Subscriber.Models
{
    public class ServiceNotificationDto
    {
        public string ServiceName { get; set; } = null!;
        public string Status { get; set; } = null!;
        public string CustomerEmail { get; set; } = null!;
        public string CustomerName { get; set; } = null!;
        public string? PhoneModel { get; set; }
    }
} 