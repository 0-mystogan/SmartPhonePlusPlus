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
    public class PartController : BaseCRUDController<PartResponse, PartSearchObject, PartUpsertRequest, PartUpsertRequest>
    {
        private readonly IPartService _partService;

        public PartController(IPartService partService) : base(partService)
        {
            _partService = partService;
        }

        [HttpGet("active")]
        public async Task<ActionResult<IEnumerable<PartResponse>>> GetActiveParts()
        {
            var parts = await _partService.GetActivePartsAsync();
            return Ok(parts);
        }

        [HttpGet("category/{categoryId}")]
        public async Task<ActionResult<IEnumerable<PartResponse>>> GetPartsByCategory(int categoryId)
        {
            var parts = await _partService.GetPartsByCategoryAsync(categoryId);
            return Ok(parts);
        }

        [HttpGet("brand/{brand}")]
        public async Task<ActionResult<IEnumerable<PartResponse>>> GetPartsByBrand(string brand)
        {
            var parts = await _partService.GetPartsByBrandAsync(brand);
            return Ok(parts);
        }

        [HttpGet("low-stock")]
        public async Task<ActionResult<IEnumerable<PartResponse>>> GetLowStockParts()
        {
            var parts = await _partService.GetLowStockPartsAsync();
            return Ok(parts);
        }

        [HttpGet("oem")]
        public async Task<ActionResult<IEnumerable<PartResponse>>> GetOEMParts()
        {
            var parts = await _partService.GetOEMPartsAsync();
            return Ok(parts);
        }

        [HttpGet("compatible/{phoneModelId}")]
        public async Task<ActionResult<IEnumerable<PartResponse>>> GetCompatibleParts(int phoneModelId)
        {
            var parts = await _partService.GetCompatiblePartsAsync(phoneModelId);
            return Ok(parts);
        }

        [HttpPut("{id}/stock")]
        public async Task<ActionResult<bool>> UpdateStockQuantity(int id, [FromBody] int quantity)
        {
            var result = await _partService.UpdateStockQuantityAsync(id, quantity);
            return Ok(result);
        }

        [HttpGet("{id}/availability")]
        public async Task<ActionResult<bool>> CheckPartAvailability(int id, [FromQuery] int requiredQuantity)
        {
            var result = await _partService.CheckPartAvailabilityAsync(id, requiredQuantity);
            return Ok(result);
        }
    }
} 