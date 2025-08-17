using SmartPhone.Model.Requests;
using SmartPhone.Model.Responses;
using SmartPhone.Model.SearchObjects;
using SmartPhone.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace SmartPhone.WebAPI.Controllers
{
    public class CartItemController : BaseCRUDController<CartItemResponse, CartItemSearchObject, CartItemUpsertRequest, CartItemUpsertRequest>
    {
        public CartItemController(ICartItemService service) : base(service)
        {
        }
    }
}
