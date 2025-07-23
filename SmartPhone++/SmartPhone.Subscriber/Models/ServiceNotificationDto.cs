using System.Collections.Generic;

namespace SmartPhone.Subscriber.Models
{
    public class ServiceNotificationDto
    {
        public string ServiceName { get; set; } = null!;
        public string Status { get; set; }
        public List<string> AdminEmails { get; set; } = new List<string>();
    }
} 