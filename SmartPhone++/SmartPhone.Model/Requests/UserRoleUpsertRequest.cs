using System.ComponentModel.DataAnnotations;

namespace SmartPhone.Model.Requests
{
    public class UserRoleUpsertRequest
    {
        [Required]
        public int UserId { get; set; }
        
        [Required]
        public int RoleId { get; set; }
    }
} 