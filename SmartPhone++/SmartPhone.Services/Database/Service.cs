using System.ComponentModel.DataAnnotations;

namespace SmartPhone.Services.Database
{
    public class Service
    {
        [Key]
        public int Id { get; set; }
        public string Name { get; set; }
        public string Status { get; set; }
    }
} 