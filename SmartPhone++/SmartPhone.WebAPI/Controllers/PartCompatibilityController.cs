using SmartPhone.Model.Requests;
using SmartPhone.Model.Responses;
using SmartPhone.Model.SearchObjects;
using SmartPhone.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;
using System.Collections.Generic;
using Microsoft.AspNetCore.Authorization;

namespace SmartPhone.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize(Roles = "Technician")]
    public class PartCompatibilityController : BaseCRUDController<PartCompatibilityResponse, PartCompatibilitySearchObject, PartCompatibilityUpsertRequest, PartCompatibilityUpsertRequest>
    {
        private readonly IPartCompatibilityService _partCompatibilityService;

        public PartCompatibilityController(IPartCompatibilityService partCompatibilityService) : base(partCompatibilityService)
        {
            _partCompatibilityService = partCompatibilityService;
        }

        [HttpGet("phone/{phoneModelId}")]
        public async Task<ActionResult<IEnumerable<PartCompatibilityResponse>>> GetCompatiblePartsForPhone(int phoneModelId)
        {
            var compatibilities = await _partCompatibilityService.GetCompatiblePartsForPhoneAsync(phoneModelId);
            return Ok(compatibilities);
        }

        [HttpGet("part/{partId}")]
        public async Task<ActionResult<IEnumerable<PartCompatibilityResponse>>> GetCompatiblePhonesForPart(int partId)
        {
            var compatibilities = await _partCompatibilityService.GetCompatiblePhonesForPartAsync(partId);
            return Ok(compatibilities);
        }

        [HttpGet("verified")]
        public async Task<ActionResult<IEnumerable<PartCompatibilityResponse>>> GetVerifiedCompatibilities()
        {
            var compatibilities = await _partCompatibilityService.GetVerifiedCompatibilitiesAsync();
            return Ok(compatibilities);
        }

        [HttpPost("part/{partId}/phone/{phoneModelId}")]
        public async Task<ActionResult<bool>> AddCompatibility(int partId, int phoneModelId, [FromBody] AddCompatibilityRequest? request = null)
        {
            var result = await _partCompatibilityService.AddCompatibilityAsync(partId, phoneModelId, request?.Notes);
            return Ok(result);
        }

        [HttpDelete("part/{partId}/phone/{phoneModelId}")]
        public async Task<ActionResult<bool>> RemoveCompatibility(int partId, int phoneModelId)
        {
            var result = await _partCompatibilityService.RemoveCompatibilityAsync(partId, phoneModelId);
            return Ok(result);
        }

        [HttpPut("{id}/verify")]
        public async Task<ActionResult<bool>> VerifyCompatibility(int id)
        {
            var result = await _partCompatibilityService.VerifyCompatibilityAsync(id);
            return Ok(result);
        }
    }

    public class AddCompatibilityRequest
    {
        public string? Notes { get; set; }
    }
} 