using SmartPhone.Model.Responses;
using SmartPhone.Model.Requests;
using SmartPhone.Model.SearchObjects;
using SmartPhone.Services.Database;

namespace SmartPhone.Services.Interfaces
{
    public interface ICartService : ICRUDService<CartResponse, CartSearchObject, CartUpsertRequest, CartUpsertRequest>
    {
        Task<List<CartResponse>> GetAllCartsForUserAsync(int userId);
        Task<CartResponse?> GetByUserIdAsync(int userId);
        Task<CartResponse> GetOrCreateCartForUserAsync(int userId);
        Task<bool> DeactivateCartAsync(int cartId, int userId);
        Task<CartSummaryResponse> GetCartSummaryAsync(int userId);
        Task<CartResponse?> GetByIdAsync(int userId);
        
        // New cart item operation methods
        Task<CartResponse> AddItemToCartAsync(int userId, int productId, int quantity);
        Task<CartResponse> UpdateItemQuantityAsync(int userId, int productId, int quantity);
        Task<CartResponse> RemoveItemFromCartAsync(int userId, int productId);
        
        // Helper method for cart operations
        Task<List<CartItem>> GetCartItemsAsync(int cartId);
        
        // Clear cart method
        Task<CartResponse> ClearCartAsync(int userId);
    }

    public class CartSummaryResponse
    {
        public int UserId { get; set; }
        public int CartId { get; set; }
        public int TotalItems { get; set; }
        public decimal TotalAmount { get; set; }
    }
}
