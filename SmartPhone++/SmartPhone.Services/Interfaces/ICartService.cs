using SmartPhone.Model.Responses;
using SmartPhone.Model.Requests;
using SmartPhone.Model.SearchObjects;

namespace SmartPhone.Services.Interfaces
{
    public interface ICartService : ICRUDService<CartResponse, CartSearchObject, CartUpsertRequest, CartUpsertRequest>
    {
        Task<CartResponse?> GetByUserIdAsync(int userId);
    }
}
