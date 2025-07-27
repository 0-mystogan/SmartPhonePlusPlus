using SmartPhone.Model.SearchObjects;

namespace SmartPhone.Model.SearchObjects
{
    public class PartCompatibilitySearchObject : BaseSearchObject
    {
        public int? PartId { get; set; }
        public int? PhoneModelId { get; set; }
        public bool? IsVerified { get; set; }
    }
} 