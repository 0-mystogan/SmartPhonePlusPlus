using SmartPhone.Model.Requests;
using SmartPhone.Model.Responses;
using SmartPhone.Model.SearchObjects;
using SmartPhone.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace SmartPhone.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ServiceController : BaseCRUDController<ServiceResponse, ServiceSearchObject, ServiceUpsertRequest, ServiceUpsertRequest>
    {
        private readonly IServiceService _serviceService;
        public ServiceController(IServiceService serviceService) : base(serviceService)
        {
            _serviceService = serviceService;
        }

        [HttpPut("{id}/complete")]
        public async Task<ActionResult<ServiceResponse>> Complete(int id)
        {
            var result = await _serviceService.CompleteAsync(id);
            return Ok(result);
        }
    }
} 