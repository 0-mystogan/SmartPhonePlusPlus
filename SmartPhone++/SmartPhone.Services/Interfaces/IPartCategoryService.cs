using SmartPhone.Services.Database;
using SmartPhone.Model.Responses;
using SmartPhone.Model.Requests;
using SmartPhone.Model.SearchObjects;

namespace SmartPhone.Services.Interfaces
{
    public interface IPartCategoryService : ICRUDService<PartCategoryResponse, PartCategorySearchObject, PartCategoryUpsertRequest, PartCategoryUpsertRequest>
    {
        Task<IEnumerable<PartCategoryResponse>> GetActiveCategoriesAsync();
        Task<IEnumerable<PartCategoryResponse>> GetSubCategoriesAsync(int parentCategoryId);
        Task<IEnumerable<PartCategoryResponse>> GetRootCategoriesAsync();
    }
} 