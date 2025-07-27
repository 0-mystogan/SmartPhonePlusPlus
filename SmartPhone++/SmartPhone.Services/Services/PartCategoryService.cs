using Microsoft.EntityFrameworkCore;
using SmartPhone.Services.Database;
using SmartPhone.Services.Interfaces;
using SmartPhone.Model.Responses;
using SmartPhone.Model.Requests;
using SmartPhone.Model.SearchObjects;
using MapsterMapper;

namespace SmartPhone.Services.Services
{
    public class PartCategoryService : BaseCRUDService<PartCategoryResponse, PartCategorySearchObject, PartCategory, PartCategoryUpsertRequest, PartCategoryUpsertRequest>, IPartCategoryService
    {
        public PartCategoryService(SmartPhoneDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public async Task<IEnumerable<PartCategoryResponse>> GetActiveCategoriesAsync()
        {
            var categories = await _context.PartCategories
                .Where(pc => pc.IsActive)
                .Include(pc => pc.ParentCategory)
                .Include(pc => pc.SubCategories.Where(sc => sc.IsActive))
                .OrderBy(pc => pc.Name)
                .ToListAsync();
            
            return categories.Select(MapToResponse).ToList();
        }

        public async Task<IEnumerable<PartCategoryResponse>> GetSubCategoriesAsync(int parentCategoryId)
        {
            var categories = await _context.PartCategories
                .Where(pc => pc.ParentCategoryId == parentCategoryId && pc.IsActive)
                .Include(pc => pc.SubCategories.Where(sc => sc.IsActive))
                .OrderBy(pc => pc.Name)
                .ToListAsync();
            
            return categories.Select(MapToResponse).ToList();
        }

        public async Task<IEnumerable<PartCategoryResponse>> GetRootCategoriesAsync()
        {
            var categories = await _context.PartCategories
                .Where(pc => pc.ParentCategoryId == null && pc.IsActive)
                .Include(pc => pc.SubCategories.Where(sc => sc.IsActive))
                .OrderBy(pc => pc.Name)
                .ToListAsync();
            
            return categories.Select(MapToResponse).ToList();
        }

        protected override PartCategoryResponse MapToResponse(PartCategory entity)
        {
            var response = _mapper.Map<PartCategoryResponse>(entity);
            response.ParentCategoryName = entity.ParentCategory?.Name;
            return response;
        }
    }
} 