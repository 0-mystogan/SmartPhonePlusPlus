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
        /// Test endpoint to debug cart data
        /// </summary>
        [HttpGet("debug/{userId}")]
        public async Task<ActionResult<object>> DebugCart(int userId)
        {
            try
            {
                _logger.LogInformation("DebugCart called for user {UserId}", userId);
                
                // Get cart without authorization for debugging
                var cart = await _cartService.GetByUserIdAsync(userId);
                _logger.LogInformation("Cart found: {CartFound}", cart != null);
                
                if (cart == null)
                {
                    return Ok(new { message = "No cart found", userId = userId });
                }

                return Ok(new { 
                    message = "Cart found",
                    cartId = cart.Id,
                    userId = cart.UserId,
                    cartItemsCount = cart.CartItems?.Count ?? 0,
                    cartItems = cart.CartItems?.Select(ci => new {
                        id = ci.Id,
                        productId = ci.ProductId,
                        productName = ci.ProductName,
                        quantity = ci.Quantity,
                        totalPrice = ci.TotalPrice
                    }).ToList()
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in DebugCart for user {UserId}", userId);
                return StatusCode(500, new { error = ex.Message, stackTrace = ex.StackTrace });
            }
        }

        /// <summary>
        /// Debug endpoint to check all carts in database
        /// </summary>
        [HttpGet("debug-all-carts")]
        public async Task<ActionResult<object>> DebugAllCarts()
        {
            try
            {
                _logger.LogInformation("DebugAllCarts called");
                
                // Get all carts from the database
                var allCarts = await _cartService.GetAsync(new CartSearchObject { RetrieveAll = true });
                
                var cartDetails = allCarts.Items.Select(c => new {
                    cartId = c.Id,
                    userId = c.UserId,
                    userName = c.UserName,
                    userEmail = c.UserEmail,
                    isActive = c.IsActive,
                    createdAt = c.CreatedAt,
                    cartItemsCount = c.CartItems?.Count ?? 0,
                    totalItems = c.TotalItems,
                    totalAmount = c.TotalAmount
                }).ToList();
                
                return Ok(new { 
                    message = $"Found {allCarts.Items.Count} carts in database",
                    totalCarts = allCarts.Items.Count,
                    carts = cartDetails
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in DebugAllCarts");
                return StatusCode(500, new { error = ex.Message, stackTrace = ex.StackTrace });
            }
        }

        /// <summary>
        /// Get the current user's cart
        /// </summary>
        [HttpGet("my-cart")]
        public async Task<ActionResult<CartResponse>> GetMyCart()
        {
            try
            {
                _logger.LogInformation("GetMyCart called");
                
                var userId = GetCurrentUserId();
                _logger.LogInformation("Current user ID: {UserId}", userId);
                
                if (userId == null)
                {
                    _logger.LogWarning("No user ID found in claims");
                    return Unauthorized("User ID not found in authentication token");
                }

                // Try to get existing cart
                var cart = await _cartService.GetByUserIdAsync(userId.Value);
                _logger.LogInformation("Cart found: {CartFound}", cart != null);
                
                if (cart == null)
                {
                    _logger.LogInformation("No active cart found for user {UserId}, creating new cart", userId.Value);
                    
                    // Create new cart for user
                    var cartRequest = new CartUpsertRequest { UserId = userId.Value };
                    cart = await _cartService.CreateAsync(cartRequest);
                    
                    _logger.LogInformation("Created new cart with ID: {CartId} for user {UserId}", cart.Id, userId.Value);
                }

                _logger.LogInformation("Returning cart with {ItemCount} items", cart.CartItems?.Count ?? 0);
                return Ok(cart);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in GetMyCart for user");
                return StatusCode(500, "Internal server error occurred while retrieving cart");
            }
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
        [HttpDelete("remove")]
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

                var cart = await _cartService.GetByUserIdAsync(userId.Value);
                if (cart == null)
                    return NotFound("No active cart found");

                // Get all cart items and delete them
                var cartItems = await _cartService.GetCartItemsAsync(cart.Id);

                foreach (var item in cartItems)
                {
                    await _cartService.RemoveItemFromCartAsync(userId.Value, item.ProductId);
                }

                return NoContent();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in ClearCart for user");
                return StatusCode(500, "Internal server error occurred while clearing cart");
            }
        }

        private int? GetCurrentUserId()
        {
            try
            {
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                _logger.LogInformation("User ID claim found: {UserIdClaim}", userIdClaim);
                
                if (int.TryParse(userIdClaim, out int userId))
                {
                    _logger.LogInformation("Successfully parsed user ID: {UserId}", userId);
                    return userId;
                }
                
                _logger.LogWarning("Failed to parse user ID from claim: {UserIdClaim}", userIdClaim);
                return null;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting current user ID from claims");
                return null;
            }
        }
    }
}
