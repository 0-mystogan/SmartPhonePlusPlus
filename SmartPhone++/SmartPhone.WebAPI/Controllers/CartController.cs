using SmartPhone.Model.Requests;
using SmartPhone.Model.Responses;
using SmartPhone.Model.SearchObjects;
using SmartPhone.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace SmartPhone.WebAPI.Controllers
{
    public class CartController : BaseCRUDController<CartResponse, CartSearchObject, CartUpsertRequest, CartUpsertRequest>
    {
        public CartController(ICartService service) : base(service)
        {
        }
    }
}
