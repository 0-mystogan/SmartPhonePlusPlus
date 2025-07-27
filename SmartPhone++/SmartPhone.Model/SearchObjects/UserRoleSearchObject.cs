using System;
using SmartPhone.Model.SearchObjects;

namespace SmartPhone.Model.SearchObjects
{
    public class UserRoleSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? RoleId { get; set; }
        public DateTime? FromDate { get; set; }
        public DateTime? ToDate { get; set; }
    }
} 