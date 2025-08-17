using SmartPhone.Model.Responses;
using SmartPhone.Model.Requests;
using SmartPhone.Model.SearchObjects;

namespace SmartPhone.Services.Interfaces
{
    public interface ICartItemService : ICRUDService<CartItemResponse, CartItemSearchObject, CartItemUpsertRequest, CartItemUpsertRequest>
    {
    }
}
