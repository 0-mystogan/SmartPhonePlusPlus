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
    }
} 