using SmartPhone.Model.Responses;
using SmartPhone.Model.Requests;
using SmartPhone.Model.SearchObjects;

namespace SmartPhone.Services.Interfaces
{
    public interface IOrderService : ICRUDService<OrderResponse, OrderSearchObject, OrderUpsertRequest, OrderUpsertRequest>
    {
        Task<IEnumerable<OrderResponse>> GetOrdersByUserAsync(int userId);
        Task<IEnumerable<OrderResponse>> GetOrdersByStatusAsync(string status);
        Task<bool> UpdateOrderStatusAsync(int orderId, string status, string? notes = null);
        Task<decimal> GetTotalSalesAsync(DateTime fromDate, DateTime toDate);
        Task<int> GetOrderCountAsync(DateTime fromDate, DateTime toDate);
        Task<OrderResponse?> GetOrderByNumberAsync(string orderNumber);
        Task<OrderResponse> CreateOrderFromCartAsync(int userId, string orderNumber, decimal totalAmount, 
            string shippingFirstName, string shippingLastName, string shippingAddress, string shippingCity, 
            string shippingPostalCode, string shippingCountry, string shippingPhone, string? shippingEmail,
            string billingFirstName, string billingLastName, string billingAddress, string billingCity,
            string billingPostalCode, string billingCountry, string billingPhone, string? billingEmail);
    }
} 