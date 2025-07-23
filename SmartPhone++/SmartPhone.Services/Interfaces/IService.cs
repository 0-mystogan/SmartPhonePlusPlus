using SmartPhone.Services.Database;
using System.Collections.Generic;
using System.Threading.Tasks;
using SmartPhone.Model.Responses;
using SmartPhone.Model.Requests;
using SmartPhone.Model.SearchObjects;

namespace SmartPhone.Services.Interfaces
{
    public interface IService<T, TSearch> where T : class where TSearch : BaseSearchObject
    {
        Task<PagedResult<T>> GetAsync(TSearch search);
        Task<T?> GetByIdAsync(int id);
    }
}