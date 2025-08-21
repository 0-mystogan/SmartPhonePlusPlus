using Microsoft.AspNetCore.Mvc;
using SmartPhone.Model.Responses;
using SmartPhone.Services.Interfaces;

namespace SmartPhone.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ProductRecommendationController : ControllerBase
    {
        private readonly IProductRecommendationService _recommendationService;

        public ProductRecommendationController(IProductRecommendationService recommendationService)
        {
            _recommendationService = recommendationService;
        }

        /// <summary>
        /// Get product recommendations for the current user based on their cart
        /// </summary>
        /// <param name="userId">ID of the current logged-in user</param>
        /// <param name="maxRecommendations">Maximum number of recommendations (default: 10)</param>
        /// <returns>List of recommended products</returns>
        [HttpGet("user/{userId}")]
        public async Task<ActionResult<List<ProductResponse>>> GetUserRecommendations(
            int userId,
            [FromQuery] int maxRecommendations = 10)
        {
            try
            {
                var recommendations = await _recommendationService.GetRecommendationsForUserAsync(userId, maxRecommendations);
                return Ok(recommendations);
            }
            catch (Exception ex)
            {
                return BadRequest($"Error getting recommendations for user {userId}: {ex.Message}");
            }
        }

        /// <summary>
        /// Get product recommendations based on provided cart data (for external calls)
        /// </summary>
        /// <param name="cartItemProductIds">Comma-separated list of product IDs in cart</param>
        /// <param name="cartItemProductNames">Comma-separated list of product names in cart</param>
        /// <param name="cartItemCategoryIds">Comma-separated list of category IDs in cart</param>
        /// <param name="maxRecommendations">Maximum number of recommendations (default: 10)</param>
        /// <returns>List of recommended products</returns>
        [HttpGet("cart-based")]
        public async Task<ActionResult<List<ProductResponse>>> GetCartBasedRecommendations(
            [FromQuery] string cartItemProductIds = "",
            [FromQuery] string cartItemProductNames = "",
            [FromQuery] string cartItemCategoryIds = "",
            [FromQuery] int maxRecommendations = 10)
        {
            try
            {
                // Parse comma-separated values
                var productIds = ParseCommaSeparatedInts(cartItemProductIds);
                var productNames = ParseCommaSeparatedStrings(cartItemProductNames);
                var categoryIds = ParseCommaSeparatedInts(cartItemCategoryIds);

                var recommendations = await _recommendationService.GetRecommendationsAsync(
                    productIds, productNames, categoryIds, maxRecommendations);

                return Ok(recommendations);
            }
            catch (Exception ex)
            {
                return BadRequest($"Error getting recommendations: {ex.Message}");
            }
        }

        private List<int> ParseCommaSeparatedInts(string commaSeparatedValues)
        {
            if (string.IsNullOrWhiteSpace(commaSeparatedValues))
                return new List<int>();

            return commaSeparatedValues.Split(',')
                .Where(s => !string.IsNullOrWhiteSpace(s))
                .Select(s => int.TryParse(s.Trim(), out var result) ? result : 0)
                .Where(id => id > 0)
                .ToList();
        }

        private List<string> ParseCommaSeparatedStrings(string commaSeparatedValues)
        {
            if (string.IsNullOrWhiteSpace(commaSeparatedValues))
                return new List<string>();

            return commaSeparatedValues.Split(',')
                .Where(s => !string.IsNullOrWhiteSpace(s))
                .Select(s => s.Trim())
                .ToList();
        }
    }
}
