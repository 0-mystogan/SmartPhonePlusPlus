using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartPhone.Model.Requests;
using SmartPhone.Model.Responses;
using SmartPhone.Model.SearchObjects;
using SmartPhone.Services.Interfaces;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace SmartPhone.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize(Roles = "Technician")]
    public class ServicePartController : BaseCRUDController<ServicePartResponse, ServicePartSearchObject, ServicePartUpsertRequest, ServicePartUpsertRequest>
    {
        private readonly IServicePartService _servicePartService;

        public ServicePartController(IServicePartService servicePartService) : base(servicePartService)
        {
            _servicePartService = servicePartService;
        }

        [HttpGet("service/{serviceId}")]
        public async Task<ActionResult<IEnumerable<ServicePartResponse>>> GetPartsForService(int serviceId)
        {
            var serviceParts = await _servicePartService.GetPartsForServiceAsync(serviceId);
            return Ok(serviceParts);
        }

        [HttpGet("part/{partId}")]
        public async Task<ActionResult<IEnumerable<ServicePartResponse>>> GetServicesForPart(int partId)
        {
            var serviceParts = await _servicePartService.GetServicesForPartAsync(partId);
            return Ok(serviceParts);
        }

        [HttpGet("service/{serviceId}/total-cost")]
        public async Task<ActionResult<decimal>> GetTotalPartsCostForService(int serviceId)
        {
            var totalCost = await _servicePartService.GetTotalPartsCostForServiceAsync(serviceId);
            return Ok(totalCost);
        }

        [HttpPost("service/{serviceId}/part/{partId}")]
        public async Task<ActionResult<bool>> AddPartToService(int serviceId, int partId, [FromBody] AddPartToServiceRequest request)
        {
            var result = await _servicePartService.AddPartToServiceAsync(
                serviceId, 
                partId, 
                request.Quantity, 
                request.UnitPrice, 
                request.DiscountAmount);
            return Ok(result);
        }

        [HttpDelete("service/{serviceId}/part/{partId}")]
        public async Task<ActionResult<bool>> RemovePartFromService(int serviceId, int partId)
        {
            var result = await _servicePartService.RemovePartFromServiceAsync(serviceId, partId);
            return Ok(result);
        }

        [HttpPut("service/{serviceId}/part/{partId}/quantity")]
        public async Task<ActionResult<bool>> UpdatePartQuantity(int serviceId, int partId, [FromBody] int quantity)
        {
            var result = await _servicePartService.UpdatePartQuantityAsync(serviceId, partId, quantity);
            return Ok(result);
        }
    }

    public class AddPartToServiceRequest
    {
        public int Quantity { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal? DiscountAmount { get; set; }
    }
} 