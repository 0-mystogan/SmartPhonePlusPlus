using SmartPhone.Model.SearchObjects;

namespace SmartPhone.Model.SearchObjects
{
    public class CurrencySearchObject : BaseSearchObject
    {
        public string? Code { get; set; }
        public string? Name { get; set; }
        public bool? IsActive { get; set; }
        public bool? IsDefault { get; set; }
    }
} 