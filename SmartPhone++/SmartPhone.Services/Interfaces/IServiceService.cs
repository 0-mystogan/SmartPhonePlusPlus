using SmartPhone.Model.Requests;
using SmartPhone.Model.Responses;
using SmartPhone.Model.SearchObjects;
using System.Threading.Tasks;

namespace SmartPhone.Services.Interfaces
{
    public interface IServiceService : ICRUDService<ServiceResponse, ServiceSearchObject, ServiceUpsertRequest, ServiceUpsertRequest>
    {
        Task<ServiceResponse> CompleteAsync(int id);
        Task<ServiceInvoiceResponse> GetInvoiceAsync(int serviceId);
    }
} 