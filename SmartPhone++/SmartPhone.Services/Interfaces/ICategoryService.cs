using SmartPhone.Model.Responses;
using SmartPhone.Model.Requests;
using SmartPhone.Model.SearchObjects;

namespace SmartPhone.Services.Interfaces
{
    public interface ICategoryService : ICRUDService<CategoryResponse, CategorySearchObject, CategoryUpsertRequest, CategoryUpsertRequest>
    {
        Task<IEnumerable<CategoryResponse>> GetActiveCategoriesAsync();
        Task<IEnumerable<CategoryResponse>> GetSubCategoriesAsync(int parentCategoryId);
        Task<IEnumerable<CategoryResponse>> GetRootCategoriesAsync();
        Task<int> GetProductCountByCategoryAsync(int categoryId);
    }
} 