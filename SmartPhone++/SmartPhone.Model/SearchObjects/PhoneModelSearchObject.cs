using SmartPhone.Model.SearchObjects;

namespace SmartPhone.Model.SearchObjects
{
    public class PhoneModelSearchObject : BaseSearchObject
    {
        public string? Brand { get; set; }
        public string? Model { get; set; }
        public string? Series { get; set; }
        public string? Year { get; set; }
        public bool? IsActive { get; set; }
    }
} 