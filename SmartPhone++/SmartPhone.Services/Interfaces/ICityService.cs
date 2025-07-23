using SmartPhone.Model.Requests;
using SmartPhone.Model.Responses;
using SmartPhone.Model.SearchObjects;

namespace SmartPhone.Services.Interfaces
{
    public interface ICityService : ICRUDService<CityResponse, CitySearchObject, CityUpsertRequest, CityUpsertRequest>
    {
    }
} 