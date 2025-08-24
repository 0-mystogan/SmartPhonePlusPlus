using SmartPhone.Model.Requests;
using SmartPhone.Model.Responses;
using SmartPhone.Model.SearchObjects;
using SmartPhone.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

namespace SmartPhone.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class CartController : BaseCRUDController<CartResponse, CartSearchObject, CartUpsertRequest, CartUpsertRequest>
    {
        private readonly ICartService _cartService;
        private readonly ILogger<CartController> _logger;

        public CartController(ICartService cartService, ILogger<CartController> logger) 
            : base(cartService)
        {
            _cartService = cartService;
            _logger = logger;
        }

        /// <summary>
        /// Add item to cart
        /// </summary>
        [HttpPost("add")]
        public async Task<ActionResult<CartResponse>> AddItemToCart([FromBody] CartItemOperationRequest request)
        {
            try
            {
                var currentUserId = GetCurrentUserId();
                if (currentUserId == null)
                    return Unauthorized("User ID not found in authentication token");

                _logger.LogInformation("AddItemToCart called with ProductId: {ProductId}, Quantity: {Quantity} for user {UserId}", 
                    request.ProductId, request.Quantity, currentUserId.Value);

                var cart = await _cartService.AddItemToCartAsync(currentUserId.Value, request.ProductId, request.Quantity);
                _logger.LogInformation("Successfully added item to cart for user {UserId}", currentUserId.Value);
                
                return Ok(cart);
            }
            catch (ArgumentException ex)
            {
                _logger.LogWarning(ex, "Invalid request in AddItemToCart for user, product {ProductId}", request.ProductId);
                return BadRequest(ex.Message);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in AddItemToCart for user, product {ProductId}", request.ProductId);
                return StatusCode(500, "Internal server error occurred while adding item to cart");
            }
        }

        /// <summary>
        /// Update item quantity in cart
        /// </summary>
        [HttpPut("update")]
        public async Task<ActionResult<CartResponse>> UpdateItemQuantity([FromBody] CartItemOperationRequest request)
        {
            try
            {
                var currentUserId = GetCurrentUserId();
                if (currentUserId == null)
                    return Unauthorized("User ID not found in authentication token");

                _logger.LogInformation("UpdateItemQuantity called with ProductId: {ProductId}, Quantity: {Quantity} for user {UserId}", 
                    request.ProductId, request.Quantity, currentUserId.Value);

                var cart = await _cartService.UpdateItemQuantityAsync(currentUserId.Value, request.ProductId, request.Quantity);
                _logger.LogInformation("Successfully updated item quantity in cart for user {UserId}", currentUserId.Value);
                
                return Ok(cart);
            }
            catch (ArgumentException ex)
            {
                _logger.LogWarning(ex, "Invalid request in UpdateItemQuantity for user, product {ProductId}", request.ProductId);
                return BadRequest(ex.Message);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in UpdateItemQuantity for user, product {ProductId}", request.ProductId);
                return StatusCode(500, "Internal server error occurred while updating item quantity");
            }
        }

        /// <summary>
        /// Remove item from cart
        /// </summary>
        [HttpPost("remove")]
        public async Task<ActionResult<CartResponse>> RemoveItemFromCart([FromBody] CartItemOperationRequest request)
        {
            try
            {
                var currentUserId = GetCurrentUserId();
                if (currentUserId == null)
                    return Unauthorized("User ID not found in authentication token");

                _logger.LogInformation("RemoveItemFromCart called with ProductId: {ProductId} for user {UserId}", 
                    request.ProductId, currentUserId.Value);

                var cart = await _cartService.RemoveItemFromCartAsync(currentUserId.Value, request.ProductId);
                _logger.LogInformation("Successfully removed item from cart for user {UserId}", currentUserId.Value);
                
                return Ok(cart);
            }
            catch (ArgumentException ex)
            {
                _logger.LogWarning(ex, "Invalid request in RemoveItemFromCart for user, product {ProductId}", request.ProductId);
                return BadRequest(ex.Message);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in RemoveItemFromCart for user, product {ProductId}", request.ProductId);
                return StatusCode(500, "Internal server error occurred while removing item from cart");
            }
        }

        /// <summary>
        /// Clear current user's cart
        /// </summary>
        [HttpDelete("clear")]
        public async Task<ActionResult> ClearCart()
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId == null)
                    return Unauthorized("User ID not found in authentication token");

                _logger.LogInformation("ClearCart called for user {UserId}", userId.Value);

                // Use the efficient clear cart method
                await _cartService.ClearCartAsync(userId.Value);
                
                _logger.LogInformation("Successfully cleared cart for user {UserId}", userId.Value);
                return NoContent();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in ClearCart for user");
                return StatusCode(500, "Internal server error occurred while clearing cart");
            }
        }

        /// <summary>
        /// Debug endpoint to check all carts for current user
        /// </summary>
        [HttpGet("debug/all-carts")]
        public async Task<ActionResult<List<CartResponse>>> GetAllCartsForCurrentUser()
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId == null)
                    return Unauthorized("User ID not found in authentication token");

                _logger.LogInformation("GetAllCartsForCurrentUser called for user {UserId}", userId.Value);

                var carts = await _cartService.GetAllCartsForUserAsync(userId.Value);
                
                _logger.LogInformation("Found {CartCount} carts for user {UserId}", carts.Count, userId.Value);
                return Ok(carts);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in GetAllCartsForCurrentUser for user");
                return StatusCode(500, "Internal server error occurred while getting carts");
            }
        }


    }
}
