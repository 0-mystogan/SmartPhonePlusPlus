using SmartPhone.Services.Database;
using SmartPhone.Model.Responses;
using SmartPhone.Model.Requests;
using SmartPhone.Model.SearchObjects;

namespace SmartPhone.Services.Interfaces
{
    public interface IServicePartService : ICRUDService<ServicePartResponse, ServicePartSearchObject, ServicePartUpsertRequest, ServicePartUpsertRequest>
    {
        Task<IEnumerable<ServicePartResponse>> GetPartsForServiceAsync(int serviceId);
        Task<IEnumerable<ServicePartResponse>> GetServicesForPartAsync(int partId);
        Task<decimal> GetTotalPartsCostForServiceAsync(int serviceId);
        Task<bool> AddPartToServiceAsync(int serviceId, int partId, int quantity, decimal unitPrice, decimal? discountAmount = null);
        Task<bool> RemovePartFromServiceAsync(int serviceId, int partId);
        Task<bool> UpdatePartQuantityAsync(int serviceId, int partId, int quantity);
    }
} 