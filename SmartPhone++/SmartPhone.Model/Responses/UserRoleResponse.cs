using System;

namespace SmartPhone.Model.Responses
{
    public class UserRoleResponse
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int RoleId { get; set; }
        public DateTime DateAssigned { get; set; }
        public string UserName { get; set; } = string.Empty;
        public string RoleName { get; set; } = string.Empty;
    }
} 