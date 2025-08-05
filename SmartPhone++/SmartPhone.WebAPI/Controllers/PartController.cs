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

        [HttpGet("debug/count")]
        public async Task<ActionResult<int>> GetPartsCount()
        {
            var search = new PartSearchObject { RetrieveAll = true };
            var result = await _partService.GetAsync(search);
            return Ok(result.Items.Count);
        }

        [HttpGet("debug/raw")]
        public async Task<ActionResult<object>> GetRawParts()
        {
            var search = new PartSearchObject { RetrieveAll = true };
            var result = await _partService.GetAsync(search);
            return Ok(new { 
                Count = result.Items.Count,
                Items = result.Items.Take(3).Select(p => new { 
                    p.Id, 
                    p.Name, 
                    p.PartCategoryId, 
                    p.PartCategoryName,
                    p.IsActive,
                    p.IsOEM,
                    p.IsCompatible
                })
            });
        }

        [HttpGet("debug/seed")]
        public async Task<ActionResult<string>> SeedDatabase()
        {
            try
            {
                // This is a temporary method to check if seeding is needed
                var search = new PartSearchObject { RetrieveAll = true };
                var result = await _partService.GetAsync(search);
                
                if (result.Items.Count == 0)
                {
                    return Ok("Database appears to be empty. Please run migrations and seed data.");
                }
                
                return Ok($"Database has {result.Items.Count} parts. Seeding appears to be working.");
            }
            catch (Exception ex)
            {
                return Ok($"Error checking database: {ex.Message}");
            }
        }
    }
} 