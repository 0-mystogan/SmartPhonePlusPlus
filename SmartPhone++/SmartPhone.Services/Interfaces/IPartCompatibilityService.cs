using SmartPhone.Services.Database;
using SmartPhone.Model.Responses;
using SmartPhone.Model.Requests;
using SmartPhone.Model.SearchObjects;

namespace SmartPhone.Services.Interfaces
{
    public interface IPartCompatibilityService : ICRUDService<PartCompatibilityResponse, PartCompatibilitySearchObject, PartCompatibilityUpsertRequest, PartCompatibilityUpsertRequest>
    {
        Task<IEnumerable<PartCompatibilityResponse>> GetCompatiblePartsForPhoneAsync(int phoneModelId);
        Task<IEnumerable<PartCompatibilityResponse>> GetCompatiblePhonesForPartAsync(int partId);
        Task<IEnumerable<PartCompatibilityResponse>> GetVerifiedCompatibilitiesAsync();
        Task<bool> AddCompatibilityAsync(int partId, int phoneModelId, string? notes = null);
        Task<bool> RemoveCompatibilityAsync(int partId, int phoneModelId);
        Task<bool> VerifyCompatibilityAsync(int compatibilityId);
    }
} 