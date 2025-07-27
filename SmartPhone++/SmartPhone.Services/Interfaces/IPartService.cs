using SmartPhone.Services.Database;
using SmartPhone.Model.Responses;
using SmartPhone.Model.Requests;
using SmartPhone.Model.SearchObjects;

namespace SmartPhone.Services.Interfaces
{
    public interface IPartService : ICRUDService<PartResponse, PartSearchObject, PartUpsertRequest, PartUpsertRequest>
    {
        Task<IEnumerable<PartResponse>> GetActivePartsAsync();
        Task<IEnumerable<PartResponse>> GetPartsByCategoryAsync(int categoryId);
        Task<IEnumerable<PartResponse>> GetPartsByBrandAsync(string brand);
        Task<IEnumerable<PartResponse>> GetLowStockPartsAsync();
        Task<IEnumerable<PartResponse>> GetOEMPartsAsync();
        Task<IEnumerable<PartResponse>> GetCompatiblePartsAsync(int phoneModelId);
        Task<bool> UpdateStockQuantityAsync(int partId, int quantity);
        Task<bool> CheckPartAvailabilityAsync(int partId, int requiredQuantity);
    }
} 