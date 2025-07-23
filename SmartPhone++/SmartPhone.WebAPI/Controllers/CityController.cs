using SmartPhone.Model.Requests;
using SmartPhone.Model.Responses;
using SmartPhone.Model.SearchObjects;
using SmartPhone.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace SmartPhone.WebAPI.Controllers
{
    public class CityController : BaseCRUDController<CityResponse, CitySearchObject, CityUpsertRequest, CityUpsertRequest>
    {
        public CityController(ICityService service) : base(service)
        {
        }
    }
} 