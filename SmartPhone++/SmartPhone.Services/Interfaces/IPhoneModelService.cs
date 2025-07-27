using SmartPhone.Services.Database;
using SmartPhone.Model.Responses;
using SmartPhone.Model.Requests;
using SmartPhone.Model.SearchObjects;

namespace SmartPhone.Services.Interfaces
{
    public interface IPhoneModelService : ICRUDService<PhoneModelResponse, PhoneModelSearchObject, PhoneModelUpsertRequest, PhoneModelUpsertRequest>
    {
        Task<IEnumerable<PhoneModelResponse>> GetActiveModelsAsync();
        Task<IEnumerable<PhoneModelResponse>> GetModelsByBrandAsync(string brand);
        Task<IEnumerable<PhoneModelResponse>> GetModelsByYearAsync(string year);
        Task<IEnumerable<PhoneModelResponse>> GetModelsBySeriesAsync(string series);
        Task<PhoneModelResponse?> GetModelByBrandAndModelAsync(string brand, string model);
    }
} 