using SmartPhone.Model.Requests;
using SmartPhone.Model.Responses;
using SmartPhone.Model.SearchObjects;

namespace SmartPhone.Services.Interfaces
{
    public interface IRoleService : ICRUDService<RoleResponse, RoleSearchObject, RoleUpsertRequest, RoleUpsertRequest>
    {
    }
}