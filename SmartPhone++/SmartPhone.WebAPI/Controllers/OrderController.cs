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
    public class OrderController : BaseCRUDController<OrderResponse, OrderSearchObject, OrderUpsertRequest, OrderUpsertRequest>
    {
        private readonly IOrderService _orderService;
        private readonly ILogger<OrderController> _logger;

        public OrderController(IOrderService orderService, ILogger<OrderController> logger) 
            : base(orderService)
        {
            _orderService = orderService;
            _logger = logger;
        }

        /// <summary>
        /// Get current user's orders
        /// </summary>
        [HttpGet("my-orders")]
        public async Task<ActionResult<IEnumerable<OrderResponse>>> GetMyOrders()
        {
            try
            {
                var currentUserId = GetCurrentUserId();
                if (currentUserId == null)
                    return Unauthorized("User ID not found in authentication token");

                _logger.LogInformation("GetMyOrders called for user {UserId}", currentUserId.Value);

                var orders = await _orderService.GetOrdersByUserAsync(currentUserId.Value);
                _logger.LogInformation("Successfully retrieved {Count} orders for user {UserId}", orders.Count(), currentUserId.Value);
                
                return Ok(orders);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in GetMyOrders for user");
                return StatusCode(500, "Internal server error occurred while retrieving orders");
            }
        }

        /// <summary>
        /// Get order by order number
        /// </summary>
        [HttpGet("by-number/{orderNumber}")]
        public async Task<ActionResult<OrderResponse>> GetOrderByNumber(string orderNumber)
        {
            try
            {
                var currentUserId = GetCurrentUserId();
                if (currentUserId == null)
                    return Unauthorized("User ID not found in authentication token");

                _logger.LogInformation("GetOrderByNumber called with OrderNumber: {OrderNumber} for user {UserId}", 
                    orderNumber, currentUserId.Value);

                var order = await _orderService.GetOrderByNumberAsync(orderNumber);
                if (order == null)
                    return NotFound("Order not found");

                // Ensure the order belongs to the current user
                if (order.UserId != currentUserId.Value)
                    return Forbid("Access denied to this order");

                _logger.LogInformation("Successfully retrieved order {OrderNumber} for user {UserId}", 
                    orderNumber, currentUserId.Value);
                
                return Ok(order);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in GetOrderByNumber for order {OrderNumber}", orderNumber);
                return StatusCode(500, "Internal server error occurred while retrieving order");
            }
        }

        /// <summary>
        /// Create order from cart
        /// </summary>
        [HttpPost("create-from-cart")]
        public async Task<ActionResult<OrderResponse>> CreateOrderFromCart([FromBody] CreateOrderFromCartRequest request)
        {
            try
            {
                var currentUserId = GetCurrentUserId();
                if (currentUserId == null)
                    return Unauthorized("User ID not found in authentication token");

                _logger.LogInformation("CreateOrderFromCart called for user {UserId} with order number {OrderNumber}", 
                    currentUserId.Value, request.OrderNumber);

                var order = await _orderService.CreateOrderFromCartAsync(
                    currentUserId.Value,
                    request.OrderNumber,
                    request.TotalAmount,
                    request.ShippingFirstName,
                    request.ShippingLastName,
                    request.ShippingAddress,
                    request.ShippingCity,
                    request.ShippingPostalCode,
                    request.ShippingCountry,
                    request.ShippingPhone,
                    request.ShippingEmail,
                    request.BillingFirstName,
                    request.BillingLastName,
                    request.BillingAddress,
                    request.BillingCity,
                    request.BillingPostalCode,
                    request.BillingCountry,
                    request.BillingPhone,
                    request.BillingEmail
                );

                _logger.LogInformation("Successfully created order {OrderNumber} for user {UserId}", 
                    request.OrderNumber, currentUserId.Value);
                
                return Ok(order);
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogWarning(ex, "Invalid operation in CreateOrderFromCart for user");
                return BadRequest(ex.Message);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in CreateOrderFromCart for user");
                return StatusCode(500, "Internal server error occurred while creating order");
            }
        }


    }
}
