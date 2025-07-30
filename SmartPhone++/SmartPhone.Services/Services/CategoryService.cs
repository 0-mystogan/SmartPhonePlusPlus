using Microsoft.EntityFrameworkCore;
using SmartPhone.Services.Database;
using SmartPhone.Services.Interfaces;
using SmartPhone.Model.Responses;
using SmartPhone.Model.Requests;
using SmartPhone.Model.SearchObjects;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SmartPhone.Services.Services
{
    public class CategoryService : BaseCRUDService<CategoryResponse, CategorySearchObject, Category, CategoryUpsertRequest, CategoryUpsertRequest>, ICategoryService
    {
        public CategoryService(SmartPhoneDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public async Task<IEnumerable<CategoryResponse>> GetActiveCategoriesAsync()
        {
            var categories = await _context.Categories
                .Where(c => c.IsActive)
                .Include(c => c.ParentCategory)
                .Include(c => c.SubCategories.Where(sc => sc.IsActive))
                .OrderBy(c => c.Name)
                .ToListAsync();
            
            return categories.Select(MapToResponse).ToList();
        }

        public async Task<IEnumerable<CategoryResponse>> GetSubCategoriesAsync(int parentCategoryId)
        {
            var categories = await _context.Categories
                .Where(c => c.ParentCategoryId == parentCategoryId && c.IsActive)
                .Include(c => c.SubCategories.Where(sc => sc.IsActive))
                .OrderBy(c => c.Name)
                .ToListAsync();
            
            return categories.Select(MapToResponse).ToList();
        }

        public async Task<IEnumerable<CategoryResponse>> GetRootCategoriesAsync()
        {
            var categories = await _context.Categories
                .Where(c => c.ParentCategoryId == null && c.IsActive)
                .Include(c => c.SubCategories.Where(sc => sc.IsActive))
                .OrderBy(c => c.Name)
                .ToListAsync();
            
            return categories.Select(MapToResponse).ToList();
        }

        public async Task<int> GetProductCountByCategoryAsync(int categoryId)
        {
            return await _context.Products
                .Where(p => p.CategoryId == categoryId && p.IsActive)
                .CountAsync();
        }

        protected override CategoryResponse MapToResponse(Category entity)
        {
            var response = _mapper.Map<CategoryResponse>(entity);
            response.ParentCategoryName = entity.ParentCategory?.Name;
            return response;
        }
    }
} 