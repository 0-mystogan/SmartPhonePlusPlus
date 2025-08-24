using SmartPhone.Model;
using SmartPhone.Model.SearchObjects;
using SmartPhone.Model.Responses;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using SmartPhone.Services.Interfaces;
using System.Security.Claims;
using Microsoft.Extensions.Logging;

namespace SmartPhone.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class BaseController<T, TSearch> : ControllerBase where T : class where TSearch : BaseSearchObject, new()
    {
        protected readonly IService<T, TSearch> _service;
        
        public BaseController(IService<T, TSearch> service) {
            _service = service;
        }

        [HttpGet("")]
        public virtual async Task<PagedResult<T>> Get([FromQuery]TSearch? search = null)
        {
            return await _service.GetAsync(search ?? new TSearch());
        }

        [HttpGet("{id}")]
        public virtual async Task<T?> GetById(int id)
        {
            return await _service.GetByIdAsync(id);
        }

        protected int? GetCurrentUserId()
        {
            try
            {
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                Console.WriteLine($"BaseController: User ID claim found: {userIdClaim}");
                
                if (int.TryParse(userIdClaim, out int userId))
                {
                    Console.WriteLine($"BaseController: Successfully parsed user ID: {userId}");
                    return userId;
                }
                
                Console.WriteLine($"BaseController: Failed to parse user ID from claim: {userIdClaim}");
                return null;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"BaseController: Error getting current user ID from claims: {ex.Message}");
                return null;
            }
        }
    }
}
