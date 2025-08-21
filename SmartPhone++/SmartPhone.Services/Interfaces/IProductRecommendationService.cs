using SmartPhone.Model.Responses;

namespace SmartPhone.Services.Interfaces
{
    public interface IProductRecommendationService
    {
            /// <summary>
    /// Get product recommendations based on cart items for a specific user
    /// </summary>
    /// <param name="userId">ID of the current logged-in user</param>
    /// <param name="maxRecommendations">Maximum number of recommendations to return</param>
    /// <returns>List of recommended products</returns>
    Task<List<ProductResponse>> GetRecommendationsForUserAsync(int userId, int maxRecommendations = 10);
    
    /// <summary>
    /// Get product recommendations based on provided cart data (for external calls)
    /// </summary>
    /// <param name="cartItemProductIds">List of product IDs currently in cart</param>
    /// <param name="cartItemProductNames">List of product names currently in cart</param>
    /// <param name="cartItemCategoryIds">List of category IDs currently in cart</param>
    /// <param name="maxRecommendations">Maximum number of recommendations to return</param>
    /// <returns>List of recommended products</returns>
    Task<List<ProductResponse>> GetRecommendationsAsync(
        List<int> cartItemProductIds,
        List<string> cartItemProductNames,
        List<int> cartItemCategoryIds,
        int maxRecommendations = 10);
    }
}
