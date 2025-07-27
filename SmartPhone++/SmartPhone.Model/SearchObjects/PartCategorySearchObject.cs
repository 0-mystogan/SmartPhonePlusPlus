using SmartPhone.Model.SearchObjects;

namespace SmartPhone.Model.SearchObjects
{
    public class PartCategorySearchObject : BaseSearchObject
    {
        public string? Name { get; set; }
        public bool? IsActive { get; set; }
        public int? ParentCategoryId { get; set; }
    }
} 