using SmartPhone.Model.Requests;
using SmartPhone.Model.Responses;
using SmartPhone.Model.SearchObjects;
using SmartPhone.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Linq;

namespace SmartPhone.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class CategoryController : BaseCRUDController<CategoryResponse, CategorySearchObject, CategoryUpsertRequest, CategoryUpsertRequest>
    {
        private readonly ICategoryService _categoryService;

        public CategoryController(ICategoryService categoryService) : base(categoryService)
        {
            _categoryService = categoryService;
        }

        [HttpGet("active")]
        public async Task<ActionResult<IEnumerable<CategoryResponse>>> GetActiveCategories()
        {
            var categories = await _categoryService.GetActiveCategoriesAsync();
            return Ok(categories);
        }

        [HttpGet("root")]
        public async Task<ActionResult<IEnumerable<CategoryResponse>>> GetRootCategories()
        {
            var categories = await _categoryService.GetRootCategoriesAsync();
            return Ok(categories);
        }

        [HttpGet("subcategories/{parentCategoryId}")]
        public async Task<ActionResult<IEnumerable<CategoryResponse>>> GetSubCategories(int parentCategoryId)
        {
            var categories = await _categoryService.GetSubCategoriesAsync(parentCategoryId);
            return Ok(categories);
        }

        [HttpGet("{id}/product-count")]
        public async Task<ActionResult<int>> GetProductCountByCategory(int id)
        {
            var count = await _categoryService.GetProductCountByCategoryAsync(id);
            return Ok(count);
        }
    }
} 