using SmartPhone.Model.Requests;
using SmartPhone.Model.Responses;
using SmartPhone.Model.SearchObjects;
using SmartPhone.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace SmartPhone.WebAPI.Controllers
{
    public class PartCategoryController : BaseCRUDController<PartCategoryResponse, PartCategorySearchObject, PartCategoryUpsertRequest, PartCategoryUpsertRequest>
    {
        public PartCategoryController(IPartCategoryService service) : base(service)
        {
        }
    }
}